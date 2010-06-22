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
      @user = User.generate_with_protected!
      User.current = @user
    end

    context "with a project" do
      context "that doesn't allow joining" do
        should 'render nothing' do
          assert hook(:project => @project).blank?
        end
      end

      context "that allows self subscribing" do
        setup do
          @project.project_subscription = 'self-subscribe'
          @project.save!
        end

        context "for a non-member" do
          should "render the self subscribe partial" do
            @controller.expects(:render_to_string).with(:partial => 'join_projects/self_subscribe_sidebar',
                                                        :locals => {:project => @project}).returns('')
            @response.body = hook(:project => @project)
          end
        end

        context "for a member" do
          should "render nothing" do
            Member.generate!(:principal => @user, :project => @project, :roles => [Role.generate!])
            assert hook(:project => @project).blank?
          end
        end

        context "for an anonymous user" do
          should "render nothing" do
            User.current = nil
            assert hook(:project => @project).blank?
          end
        end
      end

      context "that allows request to join" do
        setup do
          @project.project_subscription = 'request'
          @project.save!
        end

        context "for a non-member" do
          should "render the request to join partial" do
            @controller.expects(:render_to_string).with(:partial => 'join_projects/request_to_join_sidebar',
                                                        :locals => {:project => @project}).returns('')
            @response.body = hook(:project => @project)
          end
        end

        context "for a member" do
          should "render nothing" do
            Member.generate!(:principal => @user, :project => @project, :roles => [Role.generate!])
            assert hook(:project => @project).blank?
          end
        end

        context "for a user who already has a request to join" do
          should "render nothing" do
            assert ProjectJoinRequest.create_request(@user, @project)
            assert hook(:project => @project).blank?
          end
        end

        context "for an anonymous user" do
          should "render nothing" do
            User.current = nil
            assert hook(:project => @project).blank?
          end
        end

      end

    end
  end
end
