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
      @db = session[:mole_db]
      App.current_db( @db ) if @db      
      app_name, env = App.get_app_info
      @app_info = { :name => app_name, :env => env }
      session[:app_info] = @app_info
    end    
end
