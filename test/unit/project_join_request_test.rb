require 'test_helper'

class ProjectJoinRequestTest < ActiveSupport::TestCase
  should_belong_to :user
  should_belong_to :project

  should_allow_values_for :status, '', 'new', 'accepted', 'declined'
  should_not_allow_values_for :status, 'other', 'random text'

  context "#after_save callback" do
    should "send an email to the project members who can approve the request" do
      project = Project.generate!
      manager = User.generate_with_protected!
      manager_role = Role.generate!(:permissions => [:approve_project_join_requests])
      Member.generate!(:principal => manager, :project => project, :roles => [manager_role], :mail_notification => true)
      ProjectJoinRequest.generate!(:user => User.generate_with_protected!,
                                   :project => project)
      
      assert_sent_email
    end
  end

  context "#pending_requests_to_manage" do
    setup do
      @project = Project.generate!(:project_subscription => 'request')
      @manager = User.generate_with_protected!
      @manager_role = Role.generate!(:permissions => [:approve_project_join_requests])
      Member.generate!(:principal => @manager, :project => @project, :roles => [@manager_role])

      # New requests
      @new1 = ProjectJoinRequest.generate!(:project => @project, :user => User.generate_with_protected!, :status => 'new')
      @new2 = ProjectJoinRequest.generate!(:project => @project, :user => User.generate_with_protected!, :status => 'new')
      # Old requests
      @previous1 = ProjectJoinRequest.generate!(:project => @project, :user => User.generate_with_protected!, :status => 'accepted')
      @previous2 = ProjectJoinRequest.generate!(:project => @project, :user => User.generate_with_protected!, :status => 'declined')

      @other_project = Project.generate!(:project_subscription => 'request')
      @other_join_request = ProjectJoinRequest.generate!(:project => @other_project, :user => User.generate_with_protected!, :status => 'new')

      User.current = @manager
    end
    
    should "only return new requests" do
      assert_equal 2, ProjectJoinRequest.pending_requests_to_manage.count
      assert ProjectJoinRequest.pending_requests_to_manage.include?(@new1)
      assert ProjectJoinRequest.pending_requests_to_manage.include?(@new2)
    end
    
    should "not include requests on projects the user doesn't have permission to access" do
      assert !ProjectJoinRequest.pending_requests_to_manage.include?(@other_join_request)
    end
  end

  context "#decline!" do
    should "send an email to the requester" do
      @join_request = ProjectJoinRequest.generate!(:user => User.generate_with_protected!,
                                                   :project => Project.generate!)
      ActionMailer::Base.deliveries.clear

      @join_request.decline!
    
      assert_sent_email
    end
  end
end
