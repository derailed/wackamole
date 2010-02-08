require 'chronic'

module Mission
  # ---------------------------------------------------------------------------
  get '/' do
    # reset app info
    session[:app_info] = @app_info = nil
  
    last_tick           = session[:last_tick]
    last_tick           ||= Chronic.parse( "#{@refresh_rate} seconds ago" )
    session[:last_tick] = Time.now
    
    @pulse = Wackamole::Mission.pulse( last_tick.utc )
              
    erb :'mission/index'
  end
  
  # ---------------------------------------------------------------------------
  get '/mission/refresh' do
    last_tick           = session[:last_tick]
    last_tick           ||= Chronic.parse( "#{@refresh_rate} seconds ago" )
    session[:last_tick] = Time.now
      
    @pulse = Wackamole::Mission.pulse( last_tick.utc )

    erb :'/mission/refresh_js', :layout => false
  end

  # # ---------------------------------------------------------------------------
  # get '/mission/fixed/:app/:env/:type' do
  #   Wackamole::Mission.reset!( params[:app], params[:env], params[:type] )
  #   erb :'/mission/refresh_js', :layout => false
  # end  
end