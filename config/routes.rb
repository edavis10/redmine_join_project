ActionController::Routing::Routes.draw do |map|
  map.resources :join_projects, :path_prefix => '/projects/:project_id', :only => [:create], :as => 'join'
  map.resources :join_project_requests, :path_prefix => '/projects/:project_id', :only => [:create], :as => 'join_request'
end
