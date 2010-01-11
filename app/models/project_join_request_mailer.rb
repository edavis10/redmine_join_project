class ProjectJoinRequestMailer < Mailer

  def join_request(project_join_request)
    
    users = project_join_request.project.notified_users.collect do |user|
      user.mail if user.allowed_to?(:approve_project_join_requests, project_join_request.project)
    end.compact

    recipients users
    subject "[#{project_join_request.project.name}] #{l(:join_project_text_request_to_join)}"

    body({:project_join_request => project_join_request})
    render_multipart('join_request', body)
  end
end
