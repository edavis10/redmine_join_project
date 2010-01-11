require 'test_helper'

class ProjectJoinRequestObserverTest < ActiveSupport::TestCase
  context "#after_save callback" do
    should "send an email" do
      @project = Project.generate!(:project_subscription => 'request')
      @manager = User.generate_with_protected!
      @manager_role = Role.generate!(:permissions => [:approve_project_join_requests])
      Member.generate!(:user_id => @manager.id, :project => @project, :roles => [@manager_role])
      
      @user = User.generate_with_protected!
      @project_join_request = ProjectJoinRequest.create_request(@user, @project)
      assert_sent_email
    end
  end
end
