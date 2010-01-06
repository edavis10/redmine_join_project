class AddProjectSubscriptionToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :project_subscription, :string
  end

  def self.down
    remove_column :projects, :project_subscription
  end
end
