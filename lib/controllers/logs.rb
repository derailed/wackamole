module Logs
  
  # ---------------------------------------------------------------------------
  get "/logs/:page" do    
    page       = params[:page] ? params[:page].to_i : 1
    
    @logs        = Wackamole::Log.paginate( @filter.to_conds, page)   
    @search_path = "/logs/search"
    @filter_path = "/logs/filter"
    
    if request.xhr?
      erb :'logs/index.js', :layout => false
    else
      erb :'logs/index'
    end
  end
  
  # ---------------------------------------------------------------------------
  # Search logs - must specify a context ie ses: fred
  post "/logs/search" do
    begin
      @filter.search_terms = params[:search_filter][:search_terms]
      @logs = Wackamole::Log.paginate( @filter.to_conds )
    rescue => boom
      puts boom
      flash_it!( :error, boom )
      @logs = [].paginate
    end

    erb :"logs/filter.js", :layout => false
  end
  
  # ---------------------------------------------------------------------------
  # Fecth info about a particular log
  get "/logs/:id/show" do
    @log = Wackamole::Log.find_one( Mongo::ObjectID.from_string( params[:id] ) )
    erb :"logs/show", :layout => false 
  end
  
  # ---------------------------------------------------------------------------
  # Filter logs
  post "/logs/filter" do    
    @filter = Wackamole::SearchFilter.new
    @filter.from_options( params[:filter] )
    session[:filter] = @filter
    @logs = Wackamole::Log.paginate( @filter.to_conds )
    erb :"logs/filter.js", :layout => false
  end  
end