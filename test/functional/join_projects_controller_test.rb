require 'test_helper'

class JoinProjectsControllerTest < ActionController::TestCase
  context "routing" do
    should_route :post, "/projects/testingroutes/join", { :controller => 'join_projects', :action => :create, :project_id => 'testingroutes' }
  end

  should_have_before_filter :find_project
  should_have_before_filter :authorize

  context "on POST to :create on visible project" do
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

      should_assign_to :member
      should_redirect_to("the project overview") { "/projects/#{@project.to_param}" }
      should_set_the_flash_to(/Successful creation/i)

      should "create a new Member for the current user on the project" do
        @user.reload
        assert @user.member_of?(@project), "Membership not created"
        
        @configured_roles.each do |role|
          assert @user.roles_for_project(@project).include?(role), "Missing the configured role of #{role}"
        end
      end
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

    context "with an invalid member" do
      setup do
        setup_plugin_configuration
        @project = Project.generate!(:project_subscription => 'self-subscribe')
        @user = User.generate_with_protected!
        @request.session[:user_id] = @user.id

        assert !@user.member_of?(@project)
        assert Project.all(:conditions => Project.visible_by(@user)).include?(@project)

        # Stub save to fail
        Member.any_instance.stubs(:save).returns(false)
        post :create, :project_id => @project.to_param
      end

      should_assign_to :member
      should_redirect_to("the project overview") { "/projects/#{@project.to_param}" }
      should_set_the_flash_to(/Unable to join/i)

      should "not create a new Member for the current user on the project" do
        @user.reload
        assert !@user.member_of?(@project), "Membership created"
      end
    end

    context "with no logged in user" do
      setup do
        setup_plugin_configuration
        @project = Project.generate!(:project_subscription => 'self-subscribe')
        
        post :create, :project_id => @project.to_param
      end

      should_respond_with :redirect
      should_redirect_to("login") { {:controller => 'account', :action => 'login'} }
    end

  end

  context "on POST to :create on an unauthorized project" do
    setup do
      setup_plugin_configuration
      @project = Project.generate!(:project_subscription => 'self-subscribe', :is_public => false)
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
