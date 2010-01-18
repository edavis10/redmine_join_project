require 'redmine'

require 'join_project/hooks/layout_hooks'
require 'join_project/hooks/project_hooks'

require 'dispatcher'
Dispatcher.to_prepare :redmine_join_project do
  require_dependency 'project'
  Project.send(:include, JoinProject::Patches::ProjectPatch)

  # Remove the load the observer so it's registered for each request.
  ActiveRecord::Base.observers.delete(:project_join_request_observer)
  ActiveRecord::Base.observers << :project_join_request_observer
end

Redmine::Plugin.register :redmine_join_project do
  name 'Join Project'
  author 'Eric Davis'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-join'
  author_url 'http://www.littlestreamsoftware.com'
  description 'A Redmine plugin to allow non-members to join a project in Redmine'
  version '0.1.0'

  requires_redmine :version_or_higher => '0.8.0'

  permission(:approve_project_join_requests, {
               :join_project_requests => [:accept, :decline]
             })
  permission(:join_projects, {
               :join_projects => :create,
               :join_project_requests => :create
             }, :public => true)

  settings({
             :partial => 'settings/redmine_join_project',
             :default => {
               'roles' => [],
               'email_content' => 'A user would like to join your project. To approve or deny the request, use the link below:'
             }})
end


