module Features
  
  # ---------------------------------------------------------------------------
  # paginate top features
  get "/features/:page" do
    page = params[:page] ? params[:page].to_i : 1
        
puts @filter.inspect
        
    @features    = Wackamole::Feature.paginate_tops( @filter.to_conds, page )   
    @search_path = "/features/search"
    @filter_path = "/features/filter"
       
    if request.xhr?
      erb :'features/index.js', :layout => false
    else
      erb :'features/index'
    end
  end
  
  # ---------------------------------------------------------------------------
  # Search - must specify a context ie ses: fred
  post "/features/search" do
    begin      
      @filter.search_terms = params[:search_filter][:search_terms]      
      @features = Wackamole::Feature.paginate_tops( @filter.to_conds )
    rescue => boom
      logger.error boom
      flash[:error] = boom
      @features = [].paginate
    end

    erb :"features/filter.js", :layout => false
  end
    
  # ---------------------------------------------------------------------------
  # Filter
  post "/features/filter" do
    @filter.from_options( params[:filter] )
    session[:filter] = @filter
puts "Setting #{session[:filter].inspect}"        
    @features = Wackamole::Feature.paginate_tops( @filter.to_conds )
    erb :"features/filter.js", :layout => false
  end  
end