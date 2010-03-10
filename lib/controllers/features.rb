module Features
  
  # ---------------------------------------------------------------------------
  # paginate top features
  get "/features/:page" do
    page         = params[:page] ? params[:page].to_i : 1        
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
      # puts boom      
      flash_it!( :error, boom )
      @filter.search_terms = nil      
      @features = [].paginate
    end

    erb :"features/filter.js", :layout => false
  end
    
  # ---------------------------------------------------------------------------
  # Filter
  post "/features/filter" do
    @filter.from_options( params[:filter] )
    session[:filter] = @filter
    @features = Wackamole::Feature.paginate_tops( @filter.to_conds )
    erb :"features/filter.js", :layout => false
  end  
end