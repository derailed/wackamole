require 'rackamole'
require 'core_ext/time'

class AppsController < ApplicationController
  
  layout 'base'
  
  before_filter :ensure_db
  
  # ---------------------------------------------------------------------------
  # Home sweet home  
  def index
    now = @updated_on.utc
    @info = App.collect_dashboard_info( now )
  end
  
  # ---------------------------------------------------------------------------
  # Show the details of an application given a report id
  def open
    # Switch db context
    report  = Report.find_one( Mongo::ObjectID.from_string( params[:report_id] ) )  
    db_name = App.switch_db!( report['app'],  params[:env] )
    
    logger.info "Now connected to db #{db_name}"
    
    # Stash current db name...
    session[:mole_db] = db_name
    
    # Reset app info
    session[:app_info] = nil
    load_app_info
    
    @filter.reset!
    
    now   = @updated_on.utc  
    @info = App.collect_dashboard_info( now )
        
    render :index        
  end
  
  # ---------------------------------------------------------------------------
  # Refresh loop  
  def refresh
    render :update do |page|
      page.redirect_to :action => :index
    end
  end
  
  # ===========================================================================
  private
  
    # Ensure the db sticks
    def ensure_db
      @db = session[:mole_db]
      App.current_db( @db ) if @db
      load_app_info
    end
end