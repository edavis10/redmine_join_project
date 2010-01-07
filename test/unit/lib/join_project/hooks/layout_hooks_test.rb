require 'test_helper'

class JoinProject::Hooks::LayoutHooksTest < ActionController::TestCase
  include Redmine::Hook::Helper
  def controller
    @controller ||= WelcomeController.new
    @controller.response ||= ActionController::TestResponse.new
    @controller
  end

  def request
    @request ||= ActionController::TestRequest.new
  end
  
  def hook(args={})
    call_hook :view_layouts_base_sidebar, args.merge(:controller => @controller)
  end

  context "#view_layouts_base_sidebar" do
    setup do
      @project = Project.generate!
    end

    context "with a project" do
      context "project doesn't allow joining" do
        should 'render nothing' do
          assert hook(:project => @project).blank?
        end
      end

      context "project allow self subscribing" do
        setup do
          @project.project_subscription = 'self-subscribe'
          @project.save!
        end

        should "render the self subscribe partial" do
          @controller.expects(:render_to_string).with(:partial => 'join_projects/self_subscribe_sidebar',
                                                      :locals => {:project => @project}).returns('')
          @response.body = hook(:project => @project)
        end
      end
    end
  end
end
