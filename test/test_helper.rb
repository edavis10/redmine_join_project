# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

Rails::Initializer.run do |config|
  config.gem "webrat"
end

Webrat.configure do |config|
  config.mode = :rails
end

class ActiveSupport::TestCase
  def setup
    setup_anonymous_role
    setup_non_member_role
  end
  
  def setup_anonymous_role
    @anon_role = Role.generate!
    @anon_role.update_attribute(:builtin, Role::BUILTIN_ANONYMOUS)
  end

  def setup_non_member_role
    @non_member_role = Role.generate!
    @non_member_role.update_attribute(:builtin, Role::BUILTIN_NON_MEMBER)
  end
  
  def configure_plugin(fields={})
    Setting.plugin_redmine_join_project = fields.stringify_keys
  end

  def setup_plugin_configuration
    @configured_roles = [Role.generate!, Role.generate!]
    configure_plugin({
                       'roles' => @configured_roles.collect(&:id).collect(&:to_s),
                     })
  end
end
