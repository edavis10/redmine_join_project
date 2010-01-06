require 'test_helper'

class JoinProject::Hooks::ProjectHooksTest < ActionController::TestCase
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
    call_hook :view_projects_form, args
  end

  context "#view_projects_form" do
    setup do
      @form = mock
      @form.expects(:select)
      @project = Project.generate!
    end

    should 'render a select field for the project subscription options' do
      @response.body = hook(:project => @project, :form => @form)
    end
  end
end
