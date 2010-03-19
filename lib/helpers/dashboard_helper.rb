module DashboardHelper
  
  helpers do    
    
    # # -------------------------------------------------------------------------
    # # Make sure all indexes are set
    # def ensure_indexes!
    #   Wackamole::Log.ensure_indexes!
    #   Wackamole::User.ensure_indexes!
    #   Wackamole::Feature.ensure_indexes!      
    # end
    
    # -------------------------------------------------------------------------  
    # Retrieve moled app info...
    def load_app_info
      tokens = session[:context].split( "." )
      
      @app_info = {}
      @app_info[:zone]  = tokens[0]
      @app_info[:app]   = tokens[1]
      @app_info[:stage] = tokens[2]
      session[:app_info] = @app_info
    end
    
    # -------------------------------------------------------------------------
    # Loads the application details
    def load_app_details
      @info = Wackamole::MoledInfo.collect_dashboard_info( @updated_on.clone.utc )
    end
    
    # -------------------------------------------------------------------------
    # Check for zeroed out series...
    def zeroed_series?( series )
      series.inject(0) { |res, s| res + s } == 0
    end
  end
end
