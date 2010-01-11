class ProjectJoinRequestObserver < ActiveRecord::Observer
  unloadable
  
  def after_create(join_request)
    ProjectJoinRequestMailer.deliver_join_request(join_request)
  end
end
