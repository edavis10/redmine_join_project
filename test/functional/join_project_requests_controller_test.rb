require 'test_helper'

class JoinProjectRequestsControllerTest < ActionController::TestCase
  context "routing" do
    should_route :post, "/projects/testingroutes/join_request", { :controller => 'join_project_requests', :action => :create, :project_id => 'testingroutes' }

    should_route :get, "/projects/testingroutes/join_request/100/accept", { :controller => 'join_project_requests', :action => :accept, :project_id => 'testingroutes', :id => '100'}
    should_route :put, "/projects/testingroutes/join_request/100/accept", { :controller => 'join_project_requests', :action => :accept, :project_id => 'testingroutes', :id => '100'}

    should_route :get, "/projects/testingroutes/join_request/100/decline", { :controller => 'join_project_requests', :action => :decline, :project_id => 'testingroutes', :id => '100'}
    should_route :put, "/projects/testingroutes/join_request/100/decline", { :controller => 'join_project_requests', :action => :decline, :project_id => 'testingroutes', :id => '100'}
  end

  should_have_before_filter :find_project
  should_have_before_filter :authorize

  context "on POST to :create on visible project" do
    context "with request to join" do
      setup do
        ActionMailer::Base.deliveries.clear

        setup_plugin_configuration
        @project = Project.generate!(:project_subscription => 'request')
        @manager = User.generate_with_protected!(:mail => 'manager@example.com')
        @manager.update_attributes(:mail_notification => true)
        @manager_role = Role.generate!(:permissions => [:approve_project_join_requests])
        Member.generate!(:user_id => @manager.id, :project => @project, :roles => [@manager_role])

        @user = User.generate_with_protected!
        @request.session[:user_id] = @user.id

        assert !@user.member_of?(@project)
        assert Project.all(:conditions => Project.visible_by(@user)).include?(@project)
        
        post :create, :project_id => @project.to_param
      end

      should_assign_to :join_request
      should_redirect_to("the project overview") { "/projects/#{@project.to_param}" }
      should_set_the_flash_to(/contacted/i)

      should "send an email to the project members who can approve the request" do
         assert_sent_email
      end

      should "create a new request in the Join Queue" do
        request = ProjectJoinRequest.find_by_user_id_and_project_id(@user.id, @project.id)
        assert_kind_of ProjectJoinRequest, request
        assert_equal 'new', request.status
      end
    end

    context "with self-subscribe" do
      setup do
        setup_plugin_configuration
        @project = Project.generate!(:project_subscription => 'self-subscribe')
        @user = User.generate_with_protected!
        @request.session[:user_id] = @user.id

        assert !@user.member_of?(@project)
        assert Project.all(:conditions => Project.visible_by(@user)).include?(@project)
        
        post :create, :project_id => @project.to_param
      end

      should_respond_with 404
      should_render_template 'common/404'

    end

    context "with no user joining allowed" do
      setup do
        setup_plugin_configuration
        @project = Project.generate!(:project_subscription => 'none')
        @user = User.generate_with_protected!
        @request.session[:user_id] = @user.id

        assert !@user.member_of?(@project)
        assert Project.all(:conditions => Project.visible_by(@user)).include?(@project)
        
        post :create, :project_id => @project.to_param
      end

      should_respond_with 404
      should_render_template 'common/404'

    end

    context "with an invalid request" do
      setup do
        setup_plugin_configuration
        @project = Project.generate!(:project_subscription => 'request')
        @user = User.generate_with_protected!
        @request.session[:user_id] = @user.id

        assert !@user.member_of?(@project)
        assert Project.all(:conditions => Project.visible_by(@user)).include?(@project)

        # Stub save to fail
        ProjectJoinRequest.stubs(:create).returns(false)
        post :create, :project_id => @project.to_param
      end

      should_assign_to :join_request
      should_redirect_to("the project overview") { "/projects/#{@project.to_param}" }
      should_set_the_flash_to(/Unable to join/i)

      should "not create a new request in the Join Queue" do
        assert_nil ProjectJoinRequest.find_by_user_id_and_project_id(@user.id, @project.id)
      end
    end
  end

  context "on POST to :create on an unauthorized project" do
    setup do
      setup_plugin_configuration
      @project = Project.generate!(:project_subscription => 'request', :is_public => false)
      @user = User.generate_with_protected!
      @request.session[:user_id] = @user.id

      assert !@user.member_of?(@project)
      assert !Project.all(:conditions => Project.visible_by(@user)).include?(@project)
      
      post :create, :project_id => @project.to_param
    end

    should_respond_with 403
    should_render_template 'common/403'
  end
end
