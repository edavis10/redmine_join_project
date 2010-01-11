require 'test_helper'

class ProjectJoinRequestMailerTest < ActiveSupport::TestCase
  context "#join_request" do
    setup do
      Setting.bcc_recipients = '1'

      @project = Project.generate!(:project_subscription => 'request')
      @manager = User.generate_with_protected!(:mail => 'manager@example.com')
      @manager.update_attributes(:mail_notification => true)
      @another_member = User.generate_with_protected!(:mail => 'member@example.com')
      @another_member.update_attributes(:mail_notification => true)
      @manager_role = Role.generate!(:permissions => [:approve_project_join_requests])
      Member.generate!(:user_id => @manager.id, :project => @project, :roles => [@manager_role])
      Member.generate!(:user_id => @another_member.id, :project => @project, :roles => [Role.generate!])
      
      @user = User.generate_with_protected!
      @project_join_request = ProjectJoinRequest.create_request(@user, @project)
      ActionMailer::Base.deliveries.clear
      
      ProjectJoinRequestMailer.deliver_join_request(@project_join_request)
    end

    should "be to the project members who can approve the request" do
      assert_sent_email do |email|
        assert email.bcc, "No members included in the BCC"
        email.bcc.include?(@manager.mail)
      end
    end

    should "have a subject" do
      assert_sent_email do |email|
        email.subject =~ /#{@project.name}.*Request to join/
      end
    end

    should "include the template email from the project settings" do
      assert_sent_email do |email|
        email.body =~ /#{Setting.plugin_redmine_join_project['email_content']}/
      end
    end

    should "include the requesting user name" do
      assert_sent_email do |email|
        email.body =~ /User: #{@user.name}/
      end
    end

    should "include the requesting user login" do
      assert_sent_email do |email|
        email.body =~ /#{@user.login}/
      end
    end

    should "include the project name" do
      assert_sent_email do |email|
        email.body =~ /Project: #{@project.name}/
      end
    end

    should "link to the accept url"
    should "link to the deny url"
  end

end
