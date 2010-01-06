require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  should_allow_values_for :project_subscription, '', 'none', 'self-subscribe', 'request'
  should_not_allow_values_for :project_subscription, 'other', 'random text'
  
  context "#self_subscribe_allowed?" do
    setup do
      @project = Project.generate!
    end
    
    should "be true when project_subscription is 'self-subscribe'" do
      @project.project_subscription = 'self-subscribe'

      assert @project.self_subscribe_allowed?
    end

    should "be false with any other value" do
      @project.project_subscription = 'none'

      assert !@project.self_subscribe_allowed?
    end
  end

  context "#request_to_join?" do
    setup do
      @project = Project.generate!
    end
    
    should "be true when project_subscription is 'request'" do
      @project.project_subscription = 'request'

      assert @project.request_to_join?
    end

    should "be false with any other value" do
      @project.project_subscription = 'none'

      assert !@project.request_to_join?
    end
  end
end
