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

  # ---------------------------------------------------------------------------
  get '/mission/logs/:app_name/:stage/:type' do
    Wackamole::Control.switch_mole_db!( params[:app_name].downcase, params[:stage] )
    
    # Set app info
    @app_info = Wackamole::Feature.get_app_info
    session[:app_info] = @app_info

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