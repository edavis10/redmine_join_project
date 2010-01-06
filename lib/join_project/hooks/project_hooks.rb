module JoinProject
  module Hooks
    class ProjectHooks < Redmine::Hook::ViewListener
      # :project
      # :form
      def view_projects_form(context={})
        content = context[:form].select(:project_subscription, Project.subscription_select_options)
        return content_tag(:p, content)
      end
    end
  end
end
