require 'chronic'
require 'json'

module Dashboard
  
  # ---------------------------------------------------------------------------
  # Show application dashboard
  get '/dashboard/:app_name/:stage' do    
    Wackamole::Control.switch_mole_db!( params[:app_name].downcase, params[:stage] )
    
    @info = Wackamole::MoledInfo.collect_dashboard_info( @updated_on )

    # Reset app info
    load_app_info

    # Reset filters    
    @filter.reset!

    erb :'dashboard/index'
  end
  
  # ---------------------------------------------------------------------------
  # Refresh dashboard
  get '/dashboard/refresh' do
    @info = Wackamole::MoledInfo.collect_dashboard_info( @updated_on )

    erb :'dashboard/refresh_js', :layout => false
  end

  # ---------------------------------------------------------------------------  
  get '/dashboard/logs/:type/:hour/' do
    # Reset filter
    filter = Wackamole::SearchFilter.new
    filter.mole_type( params[:type].to_i )
    filter.hour = params[:hour].to_i
    session[:filter] = filter
    
    redirect '/logs/1'
  end
  
  # ---------------------------------------------------------------------------  
  get '/dashboard/users/:hour/' do
    # Reset filter
    filter = Wackamole::SearchFilter.new
    filter.hour = params[:hour].to_i    
    session[:filter] = filter
    
    redirect '/users/1'
  end
end