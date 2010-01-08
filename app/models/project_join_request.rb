class ProjectJoinRequest < ActiveRecord::Base
  unloadable
  belongs_to :user
  belongs_to :project

  validates_inclusion_of :status, :in => ['new', 'accepted', 'declined'], :allow_blank => 'true'
end
