require 'test_helper'

class ProjectJoinRequestTest < ActiveSupport::TestCase
  should_belong_to :user
  should_belong_to :project

  should_allow_values_for :status, '', 'new', 'accepted', 'declined'
  should_not_allow_values_for :status, 'other', 'random text'

  context "#after_save callback" do
    should "send an email to the project members who can approve the request" do
      ProjectJoinRequest.generate!(:user => User.generate_with_protected!,
                                   :project => Project.generate!)
      
      assert_sent_email
    end
  end
end
