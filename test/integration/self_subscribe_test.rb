require 'test_helper'

class SelfSubscribeTest < ActionController::IntegrationTest

  test "joining a project with self subscribe" do
    # Pugin configuration
    @role = Role.generate!
    
    # Login
    password = 'subscribe'
    @user = User.generate_with_protected!(:password => password, :password_confirmation => password)
    log_user(@user.login, password)
    
    # Go to project
    @project = Project.generate!(:project_subscription => 'self-subscribe')
    assert @project.self_subscribe_allowed?
    get "projects/#{@project.identifier}"
    assert_response :success
    
    # Click "Join this project"
    click_link "Join this project"

    # Redirected back
    assert_response :redirected
    assert_redirected_to :controller => 'projects', :action => 'show', :id => @project.identifier
    follow_redirect!

    # Membership added
    membership = Member.find_by_user_id_and_project_id(@user.id, @project.id)
    assert_kind_of Member, membership
    assert membership.roles.include?(@role)
  end
end
