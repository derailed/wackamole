module Session
  
  # ---------------------------------------------------------------------------
  # Check auth
  get "/" do
    if console_auth?
      erb :'session/login'
    else 
      redirect '/mission'
    end
  end
  
  # ---------------------------------------------------------------------------
  # Log out  
  get "/session/delete" do
    session.clear
    redirect '/'
  end
  
  # ---------------------------------------------------------------------------
  # Check credentials
  post "/session/create" do
    if authenticate( params[:login] )
      session[:user] = params[:login][:username]
      redirect '/mission'
    else
      flash_it!( :error, "Authentication failed! Please check credentials." )      
      redirect '/'
    end
  end
end