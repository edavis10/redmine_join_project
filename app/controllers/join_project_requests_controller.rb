class JoinProjectRequestsController < ApplicationController
  unloadable
  before_filter :require_login
  before_filter :find_project, :except => [:index]
  before_filter :authorize, :except => [:index]
  before_filter :authorize_global, :only => [:index]

  def index
    @join_requests = ProjectJoinRequest.pending_requests_to_manage
  end
  
  def create
    @join_request = ProjectJoinRequest.create_request(User.current, @project)
    respond_to do |format|
      unless @join_request.new_record?
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

  def decline
    @join_request = ProjectJoinRequest.find(params[:id])
    
    respond_to do |format|
      if @join_request.decline!
        flash[:notice] = l(:join_project_successful_decline)
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
