module SessionHelper  
  helpers do
    
    # Check credentials against config file
    def authenticate( creds )
      env = Sinatra::Application.environment.to_s
      config = YAML.load_file( default_config )
      conf  = config[env]      
      ((creds['username'] == conf['auth']['user']) and (creds['password'] == conf['auth']['password']))
    end
    
    def console_auth?
      env = Sinatra::Application.environment.to_s
      config = YAML.load_file( default_config )
      conf  = config[env]
      conf['auth']
    end
    
    # Check if session has auth
    def authenticated?
      session[:user]
    end
    
    # check for login path
    def root_path?
      request.path == "/"
    end
  end
end