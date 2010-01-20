require 'chronic'

module Mission  
  
  # ---------------------------------------------------------------------------
  get '/mission' do
    # reset app info
    session[:app_info] = @app_info = nil
    
    load_report
    erb :'mission/index'
  end
  
  # ---------------------------------------------------------------------------
  get '/mission/refresh' do
    load_report
    erb :'/mission/refresh_js', :layout => false
  end

  # ---------------------------------------------------------------------------
  get '/mission/fixed/:app/:env/:type' do
    Wackamole::Mission.reset!( params[:app], params[:env], params[:type] )    
    load_report    
    erb :'/mission/refresh_js', :layout => false
  end  
  
end