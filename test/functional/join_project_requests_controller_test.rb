require 'test_helper'

class JoinProjectRequestsControllerTest < ActionController::TestCase
  context "routing" do
    should_route :get, "/join_project_requests", { :controller => 'join_project_requests', :action => :index}
    
    should_route :post, "/projects/testingroutes/join_request", { :controller => 'join_project_requests', :action => :create, :project_id => 'testingroutes' }

    should_route :get, "/projects/testingroutes/join_request/100/accept", { :controller => 'join_project_requests', :action => :accept, :project_id => 'testingroutes', :id => '100'}
    should_route :put, "/projects/testingroutes/join_request/100/accept", { :controller => 'join_project_requests', :action => :accept, :project_id => 'testingroutes', :id => '100'}

    should_route :get, "/projects/testingroutes/join_request/100/decline", { :controller => 'join_project_requests', :action => :decline, :project_id => 'testingroutes', :id => '100'}
    should_route :put, "/projects/testingroutes/join_request/100/decline", { :controller => 'join_project_requests', :action => :decline, :project_id => 'testingroutes', :id => '100'}
  end

  should_have_before_filter :find_project, :except => [:index]
  should_have_before_filter :authorize, :except => [:index]
  should_have_before_filter :authorize_global, :only => [:index]
  
  context "on GET to :index for a user with visible Project Join Requests" do
    setup do
      setup_plugin_configuration
      @request.session[:user_id] = setup_manager_for_project(:project_subscription => 'request')

      @user1 = User.generate_with_protected!
      @user2 = User.generate_with_protected!
      @join_request1 = ProjectJoinRequest.create_request(@user1, @project)
      @join_request2 = ProjectJoinRequest.create_request(@user2, @project)

      @back_url = CGI.escape("/join_project_requests")
      get :index
    end
    
    should_assign_to :join_requests
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash

    should "show links to accept the requests" do
      assert_select "a[href=?]", "/projects/#{@project.to_param}/join_request/#{@join_request1.id}/accept?back_url=#{@back_url}", :text => 'Accept request'
      assert_select "a[href=?]", "/projects/#{@project.to_param}/join_request/#{@join_request2.id}/accept?back_url=#{@back_url}", :text => 'Accept request'
    end

    should "show links to decline the requests" do
      assert_select "a[href=?]", "/projects/#{@project.to_param}/join_request/#{@join_request1.id}/decline?back_url=#{@back_url}", :text => 'Decline request'
      assert_select "a[href=?]", "/projects/#{@project.to_param}/join_request/#{@join_request2.id}/decline?back_url=#{@back_url}", :text => 'Decline request'
    end
  end

  context "on POST to :create on visible project" do
    context "with request to join" do
      setup do
        ActionMailer::Base.deliveries.clear

        setup_plugin_configuration
        setup_manager_for_project(:project_subscription => 'request')

        @user = User.generate_with_protected!
        @request.session[:user_id] = @user.id

        assert !@user.member_of?(@project)
        assert Project.all(:conditions => Project.visible_by(@user)).include?(@project)
        
        post :create, :project_id => @project.to_param
      end

      should_assign_to :join_request
      should_redirect_to("the project overview") { "/projects/#{@project.to_param}" }
      should_set_the_flash_to(/notified/i)

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
        ProjectJoinRequest.stubs(:create).returns(ProjectJoinRequest.new)
        post :create, :project_id => @project.to_param
      end

      should_assign_to :join_request
      should_redirect_to("the project overview") { "/projects/#{@project.to_param}" }
      should_set_the_flash_to(/Unable to join/i)

      should "not create a new request in the Join Queue" do
        assert_nil ProjectJoinRequest.find_by_user_id_and_project_id(@user.id, @project.id)
      end
    end

    context "with no logged in user" do
      setup do
        setup_plugin_configuration
        @request.session[:user_id] = nil
        @project = Project.generate!(:project_subscription => 'none', :is_public => true)
        
        post :create, :project_id => @project.to_param
      end

      should_respond_with :redirect
      should_redirect_to("login") { {:controller => 'account', :action => 'login'} }
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

  context "on GET to :accept on a visible project" do
    setup do
      setup_plugin_configuration
      @request.session[:user_id] = setup_manager_for_project(:project_subscription => 'request').id
      @user = User.generate_with_protected!
      @join_request = ProjectJoinRequest.create_request(@user, @project)
      
      assert !@user.member_of?(@project)
        
      get :accept, :project_id => @project.to_param, :id => @join_request.id

    end
    
    should_assign_to :join_request
    should_redirect_to("the project overview") { "/projects/#{@project.to_param}" }
    should_set_the_flash_to(/Successful creation/i)

    should "create a new Member for the current user on the project" do
      @user.reload
      assert @user.member_of?(@project), "Membership not created"
        
      @configured_roles.each do |role|
        assert @user.roles_for_project(@project).include?(role), "Missing the configured role of #{role}"
      end
    end

    should "update the join request to be 'accepted'" do
      @join_request.reload

      assert_equal 'accepted', @join_request.status
    end

  end

  context "on GET to :accept on an unauthorized project" do
    setup do
      setup_plugin_configuration
      @project = Project.generate!(:project_subscription => 'request', :is_public => false)
      @user = User.generate_with_protected!
      @request.session[:user_id] = @user.id

      assert !@user.member_of?(@project)
      assert !Project.all(:conditions => Project.visible_by(@user)).include?(@project)
      
      get :accept, :project_id => @project.to_param
    end
  
    should_respond_with 403
    should_render_template 'common/403'
  end

  context "on GET to :accept on an authorized project to an unauthorized project request" do
    setup do
      setup_plugin_configuration
      @request.session[:user_id] = setup_manager_for_project(:project_subscription => 'request')
      @user = User.generate_with_protected!
      @join_request = ProjectJoinRequest.create_request(@user, Project.generate!(:project_subscription => 'request')) # Different project
      
      assert !@user.member_of?(@project)
      
      get :accept, :project_id => @project.to_param, :id => @join_request.id
    end
  
    should_respond_with 403
    should_render_template 'common/403'
  end

  context "on GET to :decline on a visible project" do
    setup do
      setup_plugin_configuration
      @request.session[:user_id] = setup_manager_for_project(:project_subscription => 'request').id
      @user = User.generate_with_protected!
      @join_request = ProjectJoinRequest.create_request(@user, @project)
      
      assert !@user.member_of?(@project)
        
      get :decline, :project_id => @project.to_param, :id => @join_request.id

    end
    
    should_assign_to :join_request
    should_redirect_to("the project overview") { "/projects/#{@project.to_param}" }
    should_set_the_flash_to(/declined/i)

    should "update the join request to be 'declined'" do
      @join_request.reload

      assert_equal 'declined', @join_request.status
    end

  end

  context "on GET to :decline on an unauthorized project" do
    setup do
      setup_plugin_configuration
      @project = Project.generate!(:project_subscription => 'request', :is_public => false)
      @user = User.generate_with_protected!
      @request.session[:user_id] = @user.id

      assert !@user.member_of?(@project)
      assert !Project.all(:conditions => Project.visible_by(@user)).include?(@project)
      
      get :decline, :project_id => @project.to_param
    end
  
    should_respond_with 403
    should_render_template 'common/403'
  end

  context "on GET to :decline on an authorized project to an unauthorized project request" do
    setup do
      setup_plugin_configuration
      @request.session[:user_id] = setup_manager_for_project(:project_subscription => 'request')
      @user = User.generate_with_protected!
      @join_request = ProjectJoinRequest.create_request(@user, Project.generate!(:project_subscription => 'request')) # Different project
      
      assert !@user.member_of?(@project)
      
      get :decline, :project_id => @project.to_param, :id => @join_request.id
    end
  
    should_respond_with 403
    should_render_template 'common/403'
  end
end
