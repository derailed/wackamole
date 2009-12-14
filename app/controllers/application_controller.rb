require 'mongo/control'

class ApplicationController < ActionController::Base
  helper :all 
  protect_from_forgery 
    
  before_filter :setup_filter
  
  # ===========================================================================
  private

    # -------------------------------------------------------------------------
    # General setup
    def setup_filter
      @title      = 'W A C K A M O L E'
      @updated_on = 0.days.ago
      
      @filter = session[:filter]
      unless @filter
        @filter          = SearchFilter.new
        session[:filter] = @filter
      end
      load_app_info
    end

  # ===========================================================================    
  protected
  
    # -------------------------------------------------------------------------  
    # Retrieve moled app info...
    def load_app_info
      @app_info = session[:app_info]
      unless @app_info
        app_name, env = Feature.get_app_info
        @app_info     = { :name => app_name, :env => env }
        session[:app_info] = @app_info
      end
    end    
end
