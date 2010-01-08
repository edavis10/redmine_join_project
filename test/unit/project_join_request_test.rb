require 'test_helper'

class ProjectJoinRequestTest < ActiveSupport::TestCase
  should_belong_to :user
  should_belong_to :project

  should_allow_values_for :status, '', 'new', 'accepted', 'declined'
  should_not_allow_values_for :status, 'other', 'random text'
end
