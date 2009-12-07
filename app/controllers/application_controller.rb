class ApplicationController < ActionController::Base
  helper :all 
  protect_from_forgery 
    
  before_filter :setup
  
  # ===========================================================================
  private

    # -------------------------------------------------------------------------
    # General setup
    def setup
      @title      = 'W A C K A M O L E'
      @updated_on = 0.days.ago
      
      @filter = session[:filter]
      unless @filter
        @filter          = SearchFilter.new
        session[:filter] = @filter
      end
      load_app_info
    end
    
    # -------------------------------------------------------------------------  
    # Retrieve moled app info...
    def load_app_info
      @app_info = session[:app_info]
      unless @app_info
        feature = Feature.find( :first, :fields => [:app, :env] )
        @app_info = { :name => feature.app, :env => feature.env }
        session[:app_info] = @app_info
      end
    end    
end
