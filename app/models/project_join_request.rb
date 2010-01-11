class ProjectJoinRequest < ActiveRecord::Base
  unloadable
  belongs_to :user
  belongs_to :project

  validates_inclusion_of :status, :in => ['new', 'accepted', 'declined'], :allow_blank => 'true'
  validates_uniqueness_of :user_id, :scoped_to => :project_id

  def self.create_request(user, project)
    ProjectJoinRequest.create(:user => user, :project => project, :status => 'new')
  end
end
