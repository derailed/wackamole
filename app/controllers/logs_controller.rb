class LogsController < ApplicationController
  
  layout 'base'
  
  before_filter :ensure_db
  
  # ---------------------------------------------------------------------------
  # Homey...
  def index
    @logs = Log.paginate_logs( @filter.to_conds, params[:page] ? params[:page].to_i : 1 )
  end
  
  # ---------------------------------------------------------------------------
  # Search logs - must specify a context ie ses: fred
  def search
    begin
      @filter.search_terms = params[:search_filter][:search_terms]      
      @logs = Log.paginate_logs( @filter.to_conds )
    rescue => boom
      logger.error boom
      flash.now[:error] = boom
      @logs = [].paginate
    end
    
    render :filter
  end
  
  # ---------------------------------------------------------------------------
  # Fecth info about a particular log
  def show
    @log = Log.find_one( Mongo::ObjectID.from_string( params[:id] ) )
    render :show, :layout => false 
  end
  
  # ---------------------------------------------------------------------------
  # Filter logs
  def filter
    @filter.from_options( params[:filter] )
    @logs = Log.paginate_logs( @filter.to_conds )
  end
  
  # ===========================================================================
  private
  
    # Ensure the db sticks
    def ensure_db
      @db = session[:mole_db]
      Log.current_db( @db )
      Feature.current_db( @db )
      User.current_db( @db )
    end

end