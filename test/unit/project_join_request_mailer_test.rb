require 'test_helper'

class ProjectJoinRequestMailerTest < ActiveSupport::TestCase
  include ActionController::Assertions::SelectorAssertions

  context "#join_request" do
    setup do
      Setting.bcc_recipients = '1'

      @project = Project.generate!(:project_subscription => 'request')
      @manager = User.generate_with_protected!(:mail => 'manager@example.com')
      @manager.update_attributes(:mail_notification => true)
      @blocking_manager = User.generate_with_protected!(:mail => 'manager2@example.com')
      @blocking_manager.pref[:block_join_project_requests] = '1'
      @blocking_manager.pref.save
      @blocking_manager.update_attributes(:mail_notification => true)
      @another_member = User.generate_with_protected!(:mail => 'member@example.com')
      @another_member.update_attributes(:mail_notification => true)
      @manager_role = Role.generate!(:permissions => [:approve_project_join_requests])
      Member.generate!(:principal => @manager, :project => @project, :roles => [@manager_role])
      Member.generate!(:principal => @blocking_manager, :project => @project, :roles => [@manager_role])
      Member.generate!(:principal => @another_member, :project => @project, :roles => [Role.generate!])
      
      @user = User.generate_with_protected!
      @project_join_request = ProjectJoinRequest.create_request(@user, @project)
      ActionMailer::Base.deliveries.clear
      
      ProjectJoinRequestMailer.deliver_join_request(@project_join_request)
    end

    should "be sent to the project members who can approve the request" do
      assert_sent_email do |email|
        assert email.bcc, "No members included in the BCC"
        email.bcc.include?(@manager.mail)
      end
    end

    should "not include managers who are blocking project join requests" do
      assert_sent_email do |email|
        assert email.bcc, "No members included in the BCC"
        !email.bcc.include?(@blocking_manager.mail)
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

    should "link to the accept url" do
      assert_select_email do
        assert_select "a[href=?]", "http://localhost:3000/projects/#{@project.to_param}/join_request/#{@project_join_request.id}/accept", :text => 'Accept request'
      end
    end

    should "link to the deny url" do
      assert_select_email do
        assert_select "a[href=?]", "http://localhost:3000/projects/#{@project.to_param}/join_request/#{@project_join_request.id}/decline", :text => 'Decline request'
      end
    end

  end

  context "#declined_request" do
    setup do
      Setting.bcc_recipients = '1'

      @project = Project.generate!(:project_subscription => 'request')
      @user = User.generate_with_protected!
      @project_join_request = ProjectJoinRequest.create_request(@user, @project)
      @project_join_request.update_attribute(:status, 'declined')
      ActionMailer::Base.deliveries.clear
      
      ProjectJoinRequestMailer.deliver_declined_request(@project_join_request)
    end

    should "be sent the requesting user" do
      assert_sent_email do |email|
        assert email.bcc
        email.bcc.include?(@user.mail)
      end
    end
    
    should "have a subject" do
      assert_sent_email do |email|
        email.subject =~ /declined/i
      end
    end
    
    should "include the project name" do
      assert_sent_email do |email|
        email.body =~ /#{@project.name}/
      end
    end
    
    should "include a notice that the user's request was declined" do
      assert_sent_email do |email|
        email.body =~ /your request to join #{@project.name} was declined/i
      end
    end
  end
end
