require 'test_helper'

class RequestToJoinTest < ActionController::IntegrationTest

  test "joining a project with request to join" do
    ActionMailer::Base.deliveries.clear
    setup_plugin_configuration
    @project = Project.generate!(:project_subscription => 'request')

    # Manager to get emails
    @manager = User.generate_with_protected!(:mail => 'manager@example.com')
    @manager.update_attributes(:mail_notification => true)
    @manager_role = Role.generate!(:permissions => [:approve_project_join_requests])
    Member.generate!(:user_id => @manager.id, :project => @project, :roles => [@manager_role])
    
    # Login
    password = 'request'
    @user = User.generate_with_protected!(:password => password, :password_confirmation => password)
    log_user(@user.login, password)
    
    # Go to project's issues
    assert @project.request_to_join?
    get "projects/#{@project.identifier}/activity"
    assert_response :success
    
    # Click "Join this project"
    click_link "Request to join"

    # Redirected back to previous page
    assert_equal current_url, url_for(:controller => 'projects', :action => 'activity', :id => @project.identifier)
    assert_select 'div.flash.notice', /The project managers have been contacted/

    # Request added
    assert_kind_of ProjectJoinRequest, ProjectJoinRequest.find_by_user_id_and_project_id(@user.id, @project.id)

    # Email sent
    assert_sent_email
  end
end
