require 'test_helper'

class SelfSubscribeTest < ActionController::IntegrationTest

  test "joining a project with self subscribe" do
    setup_plugin_configuration
    
    # Login
    password = 'subscribe'
    @user = User.generate_with_protected!(:password => password, :password_confirmation => password)
    log_user(@user.login, password)
    
    # Go to project's issues
    @project = Project.generate!(:project_subscription => 'self-subscribe')
    assert @project.self_subscribe_allowed?
    get "projects/#{@project.identifier}/activity"
    assert_response :success
    
    # Click "Join this project"
    click_link "Join this project"

    # Redirected back to previous page
    assert_equal current_url, url_for(:controller => 'projects', :action => 'activity', :id => @project.identifier)

    # Membership added
    membership = Member.find_by_user_id_and_project_id(@user.id, @project.id)
    assert_kind_of Member, membership
    assert_equal 2, membership.roles.count
    @configured_roles.each do |role|
      assert membership.roles.include?(role)
    end
  end
end
