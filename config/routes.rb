ActionController::Routing::Routes.draw do |map|
  # Dashboard
  map.root :controller => 'dash', :action => 'index'
  map.resource :dash, :only => [:index], :collection => { :refresh => :get }

  # Users
  map.resources :users, :only => [:index], :collection => { :filter => :post, :search => :post }
  
  # Features
  map.resources :features, :only => [:index], :collection => { :filter => :post, :search => :post }  
  
  # Logs
  map.resources :logs, :only => [:index, :show], :collection => { :show_logs => :get, :filter => :post, :search => :post }

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
