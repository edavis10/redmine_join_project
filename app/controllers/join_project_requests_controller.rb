class JoinProjectRequestsController < ApplicationController
  unloadable
  before_filter :find_project
  before_filter :authorize

  def create
    @join_request = ProjectJoinRequest.create_request(User.current, @project)
    respond_to do |format|
      if @join_request
        flash[:notice] = l(:join_project_successful_request)
        format.html { redirect_back_or_default(:controller => 'projects', :action => 'show', :id => @project) }
      else
        flash[:error] = l(:join_project_error_cant_join)
        format.html { redirect_back_or_default(:controller => 'projects', :action => 'show', :id => @project) }
      end
    end
  end

  def accept
    @join_request = ProjectJoinRequest.find(params[:id])
    
    respond_to do |format|
      if @join_request.accept!
        flash[:notice] = l(:notice_successful_create)
        format.html {redirect_back_or_default(:controller => 'projects', :action => 'show', :id => @project) }
      else
        flash[:error] = l(:join_project_error_cant_join)
        format.html {redirect_back_or_default(:controller => 'projects', :action => 'show', :id => @project) }
      end
    end
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
    unless @project.request_to_join?
      render_404
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
