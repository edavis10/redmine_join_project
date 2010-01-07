module JoinProject
  module Hooks
    class LayoutHooks < Redmine::Hook::ViewListener
      def view_layouts_base_sidebar(context={})
        project = context[:project]
        return '' if project.nil?
        return '' if User.current.member_of?(project)

        case project.project_subscription
        when 'self-subscribe'
          return context[:controller].send(:render_to_string, :partial => 'join_projects/self_subscribe_sidebar', :locals => {:project => project})
        else
          return ''
        end
      end
    end
  end
end
