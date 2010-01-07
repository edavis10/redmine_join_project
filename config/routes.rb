ActionController::Routing::Routes.draw do |map|
  map.resources :join_projects, :path_prefix => '/projects/:project_id', :only => [:create], :as => 'join'
end
