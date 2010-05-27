require 'test_helper'

class RequestToJoinTest < ActionController::IntegrationTest

  def submit_request_to_join
    ActionMailer::Base.deliveries.clear
    setup_plugin_configuration
    @password = 'request'
    @project = Project.generate!(:project_subscription => 'request')

    # Manager to get emails
    @manager = User.generate_with_protected!(:login => 'manager', :mail => 'manager@example.com', :password => @password, :password_confirmation => @password)
    @manager.update_attributes(:mail_notification => true)
    @manager_role = Role.generate!(:permissions => [:approve_project_join_requests])
    Member.generate!(:principal => @manager, :project => @project, :roles => [@manager_role])
    
    # Login
    @user = User.generate_with_protected!(:password => @password, :password_confirmation => @password)
    log_user(@user.login, @password)
    
    # Go to project's issues
    assert @project.request_to_join?
    get "projects/#{@project.identifier}/activity"
    assert_response :success
    
    # Click "Join this project"
    click_link "Request to join"

    # Redirected back to previous page
    assert_equal current_url, url_for(:controller => 'projects', :action => 'activity', :id => @project.identifier)
    assert_select 'div.flash.notice', /The project managers have been notified/

    # Request added
    assert_kind_of ProjectJoinRequest, ProjectJoinRequest.find_by_user_id_and_project_id(@user.id, @project.id)

    # Email sent
    assert_sent_email

    # Logout to clear session
    get 'logout'
    assert_response :redirect
    assert_equal User.anonymous, User.current
  end

  test "joining a project with request to join" do
    submit_request_to_join
    
    ## Manager to approve
    log_user(@manager.login, @password)
    assert_equal @manager, User.current
    
    # Setup the My Page Block
    xhr :post, "my/add_block", :block => "project-join-requests"

    # Go to My Page
    get 'my/page'
    assert_response :success

    click_link "Accept request"

    # Redirected back to previous page
    assert_equal current_url, url_for(:controller => 'my', :action => 'page')
    assert_select 'div.flash.notice', /success/i

    # Membership added
    membership = Member.find_by_user_id_and_project_id(@user.id, @project.id)
    assert_kind_of Member, membership
    assert_equal 2, membership.roles.count
    @configured_roles.each do |role|
      assert membership.roles.include?(role)
    end
  end

  test "declining a request to join a project" do
    submit_request_to_join
    
    ## Manager to approve
    log_user(@manager.login, @password)
    assert_equal @manager, User.current
    
    # Setup the My Page Block
    xhr :post, "my/add_block", :block => "project-join-requests"

    # Go to My Page
    get 'my/page'
    assert_response :success

    click_link "Decline request"

    # Redirected back to previous page
    assert_equal current_url, url_for(:controller => 'my', :action => 'page')
    assert_select 'div.flash.notice', /Declined join request/i

    # No membership added
    assert_nil Member.find_by_user_id_and_project_id(@user.id, @project.id)

    # Decline mail
    assert_sent_email do |email|
      email.bcc.include?(@user.mail)
    end
  end
end
