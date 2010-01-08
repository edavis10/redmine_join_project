class CreateProjectJoinRequests < ActiveRecord::Migration
  def self.up
    create_table :project_join_requests do |t|
      t.integer :user_id
      t.integer :project_id
      t.string :status
      t.timestamps
    end

    add_index :project_join_requests, :user_id
    add_index :project_join_requests, :project_id
    add_index :project_join_requests, :status
  end

  def self.down
    drop_table :project_join_requests
  end
end
