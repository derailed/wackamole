ActionController::Routing::Routes.draw do |map|
  # Dashboard
  map.root :controller => 'reports', :action => 'index'
  
  # Mission control
  map.resources :reports, :only => [:index], :collection => { :refresh => :get }
  map.fixed '/reports/fixed/:db/:app/:env/:type', :controller => 'reports', :action => 'fixed'
  
  # Apps
  map.resources :apps, :only => [:index], :collection => { :refresh => :get }
  map.open  '/apps/open/:report_id/:env', :controller => 'apps', :action => 'open'

  # Users
  map.resources :users, :only => [:index], :collection => { :filter => :post, :search => :post }
  
  # Features
  map.resources :features, :only => [:index], :collection => { :filter => :post, :search => :post }  
  
  # Logs
  map.resources :logs, :only => [:index, :show], :collection => { :show_logs => :get, :filter => :post, :search => :post }

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
