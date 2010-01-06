module JoinProject
  module Hooks
    class ProjectHooks < Redmine::Hook::ViewListener
      # :project
      # :form
      def view_projects_form(context={})
        content = context[:form].select(:project_subscription, Project.join_options_for_select)
        return content_tag(:p, content)
      end
    end
  end
end
