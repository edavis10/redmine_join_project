require 'redmine'

Redmine::Plugin.register :redmine_join_project do
  name 'Join Project'
  author 'Eric Davis'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-join'
  author_url 'http://www.littlestreamsoftware.com'
  description 'A Redmine plugin to allow non-members to join a project in Redmine'
  version '0.1.0'

  requires_redmine :version_or_higher => '0.8.0'

end
