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
      @app_info = Wackamole::Feature.get_app_info
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
