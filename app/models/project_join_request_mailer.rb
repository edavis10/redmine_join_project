class ProjectJoinRequestMailer < Mailer

  def join_request(project_join_request)
    
    users = project_join_request.project.notified_users.collect do |user|
      if user.allowed_to?(:approve_project_join_requests, project_join_request.project)
        user.mail unless user.pref.block_join_project_requests?
      end
    end.compact

    recipients users
    subject "[#{project_join_request.project.name}] #{l(:join_project_text_request_to_join)}"

    body({:project_join_request => project_join_request})
    render_multipart('join_request', body)
  end

  def declined_request(project_join_request)
    recipients project_join_request.user.mail
    subject "[#{project_join_request.project.name}] #{l(:join_project_text_declined_request_to_join_this_project)}"
    
    body({:project_join_request => project_join_request})
    render_multipart('declined_request', body)
  end
end
