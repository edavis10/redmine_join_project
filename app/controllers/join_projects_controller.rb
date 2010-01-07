class JoinProjectsController < ApplicationController
  unloadable
  before_filter :find_project
  before_filter :authorize
  
  def create
    @member = @project.members.build
    @member.user = User.current
    @member.roles = Role.find(Setting.plugin_redmine_join_project['roles'])
    respond_to do |format|
      if @member.save
        flash[:notice] = l(:notice_successful_create)
        format.html { redirect_to(:controller => 'projects', :action => 'show', :id => @project) }
      else
        format.html { redirect_to(:controller => 'projects', :action => 'show', :id => @project) }
      end
    end
  end

  private
  
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
