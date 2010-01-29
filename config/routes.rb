ActionController::Routing::Routes.draw do |map|
  map.resources :join_projects, :path_prefix => '/projects/:project_id', :only => [:create], :as => 'join'
  map.resources :join_project_requests, :path_prefix => '/projects/:project_id', :only => [:create, :accept, :decline], :as => 'join_request', :member => {:accept => [:get, :put], :decline => [:get, :put]}
  map.resources :join_project_requests, :only => [:index]
end
