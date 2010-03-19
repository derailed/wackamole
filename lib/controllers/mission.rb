require 'chronic'

module Mission
  # ---------------------------------------------------------------------------
  get '/mission' do
    clear_flash!
    
     # reset app info
    session[:app_info] = @app_info = nil
  
    # Support store like mongodb where not allowed to peruse connection
    # in which case just show the dashboard
    if Wackamole::Control.single_app?
      app_name, stage = Wackamole::Control.app_info
      redirect "/dashboard/#{app_name}/#{stage}"
      return
    end
    
    last_tick           = session[:last_tick]
    last_tick           ||= Chronic.parse( "#{@refresh_rate} seconds ago" )
    session[:last_tick] = Time.now
    
    @zones = Wackamole::Mission.pulse( last_tick )

    erb :'mission/index'
  end
  
  # ---------------------------------------------------------------------------
  get '/mission/refresh' do
    last_tick           = session[:last_tick]
    last_tick           ||= Chronic.parse( "#{@refresh_rate} seconds ago" )
    session[:last_tick] = Time.now
      
    @zones = Wackamole::Mission.pulse( last_tick )

    erb :'/mission/refresh_js', :layout => false
  end

  # ---------------------------------------------------------------------------
  get '/mission/logs/:zone/:app/:stage/:type' do
    switch_context!( params[:zone], params[:app], params[:stage] )
    
    # Set app info
    load_app_info
    
    # Reset filter    
    filter = Wackamole::SearchFilter.new
    filter.mole_type( params[:type].to_i )
    session[:filter] = filter
    
    redirect '/logs/1'
  end

  # # ---------------------------------------------------------------------------
  # get '/mission/fixed/:app/:env/:type' do
  #   Wackamole::Mission.reset!( params[:app], params[:env], params[:type] )
  #   erb :'/mission/refresh_js', :layout => false
  # end  
end