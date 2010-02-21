module Users
  
  # ---------------------------------------------------------------------------
  # Paginate top users
  get "/users/:page" do
    page = params[:page] ? params[:page].to_i : 1
    @users = Wackamole::User.paginate_tops( @filter.to_conds, page )   

    @search_path = "/users/search"
    @filter_path = "/users/filter"
   
    if request.xhr?
      erb :'users/index.js', :layout => false
    else
      erb :'users/index'
    end
  end
  
  # ---------------------------------------------------------------------------
  # search users
  post "/users/search" do
    begin
      @filter.search_terms = params[:search_filter][:search_terms]      
      @users = Wackamole::User.paginate_tops( @filter.to_conds )
    rescue => boom
      logger.error boom
      flash[:error] = boom
      @users = [].paginate
    end

    erb :"users/filter.js", :layout => false
  end
    
  # ---------------------------------------------------------------------------
  # Filter
  post "/users/filter" do    
    @filter.from_options( params[:filter] )
    session[:filter] = @filter
    @users = Wackamole::User.paginate_tops( @filter.to_conds )
    erb :"users/filter.js", :layout => false
  end  
end