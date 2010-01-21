class ProjectJoinRequest < ActiveRecord::Base
  unloadable
  belongs_to :user
  belongs_to :project

  validates_inclusion_of :status, :in => ['new', 'accepted', 'declined'], :allow_blank => 'true'
  validates_uniqueness_of :user_id, :scope => :project_id

  named_scope :status_of, lambda { |status|
    {
      :conditions => {:status => status}
    }
  }

  named_scope :visible_to, lambda {|user|
    {
      :include => :project,
      :conditions => Project.allowed_to_condition(user, :approve_project_join_requests)
    }
  }

  def accept!
    membership = project.members.build
    membership.user = user
    membership.roles = Role.find(Setting.plugin_redmine_join_project['roles'])
    membership.save && self.update_attribute(:status, 'accepted')
  end

  def decline!
    self.update_attribute(:status, 'declined')
    ProjectJoinRequestMailer.deliver_declined_request(self)
    self
  end
  
  def self.pending_requests_to_manage(user=User.current)
    status_of('new').visible_to(user)
  end
  
  def self.create_request(user, project)
    ProjectJoinRequest.create(:user => user, :project => project, :status => 'new')
  end

  def self.pending_request_for?(user, project)
    ProjectJoinRequest.find_by_user_id_and_project_id(user.id, project.id)
  end
end
