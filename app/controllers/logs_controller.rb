class LogsController < ApplicationController
  layout 'plain'
  
  # ---------------------------------------------------------------------------
  # Homey...
  def index
    page = params[:page] || 0
    fetch_logs( @filter.to_conds, page )
  end
  
  # ---------------------------------------------------------------------------
  # Search logs - must specify a context ie ses: fred
  def search
    @filter.search_terms = params[:search_filter][:search_terms]
    begin
      conds = @filter.to_conds
    rescue => boom
      logger.error boom
      # No match flash it
      flash.now[:error] = boom
    end

    fetch_logs( conds, 0 )    
    render :filter
  end
  
  # ---------------------------------------------------------------------------
  # Fecth info about a particular log
  def show
    @log = Log.find( params[:id] )
    render :show, :layout => false 
  end
  
  # ---------------------------------------------------------------------------
  # Filter logs
  def filter
    @filter.from_options( params[:filter] )
    session[:last_pull] = nil
    fetch_logs( @filter.to_conds, 0 )
  end
  
  # ===========================================================================
  private 
      
    # -------------------------------------------------------------------------
    # Fetch pagination collection for given condition
    def fetch_logs( conds, page )
      last_pull = session[:last_pull]
      
      @logs   = Log.paginate( 
        :conditions => conds, 
        :sort       => [ ['did', 'desc'], ['tid', 'desc'] ], 
        :per_page   => 15, 
        :page       => page )
      
      @logs.each { |log| log[:recent] = (log.timestamp and last_pull and log.timestamp > last_pull) }
      session[:last_pull] = @logs.first.timestamp if !@logs.empty? and last_pull and last_pull > @logs.first.timestamp
    end
        
    # -------------------------------------------------------------------------
    # pagination page size
    def per_page
      15
    end    
end