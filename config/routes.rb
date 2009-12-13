ActionController::Routing::Routes.draw do |map|
  # Dashboard
  map.root :controller => 'apps', :action => 'index'
  
  # Mission control
  map.resources :reports, :only => [:index], :collection => { :refresh => :get }
  map.fixed 'reports/fixed/:db/:app/:env/:type', :controller => 'reports', :action => 'fixed'
  
  # Dash
  map.resources :apps, :only => [:index], :collection => { :refresh => :get }

  # Users
  map.resources :users, :only => [:index], :collection => { :filter => :post, :search => :post }
  
  # Features
  map.resources :features, :only => [:index], :collection => { :filter => :post, :search => :post }  
  
  # Logs
  map.resources :logs, :only => [:index, :show], :collection => { :show_logs => :get, :filter => :post, :search => :post }

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
