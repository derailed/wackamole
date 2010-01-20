require 'chronic'
require 'json'

module Dashboard
  
  # ---------------------------------------------------------------------------
  # Show application dashboard
  get '/dashboard/:app_name/:stage' do    
    Wackamole::Control.switch_mole_db!( params[:app_name].downcase, params[:stage] )
    
    ensure_indexes!
    load_app_details

    # Reset app info
    load_app_info

    # Reset filters    
    @filter.reset!

    erb :'dashboard/index'
  end
  
  # ---------------------------------------------------------------------------
  # Refresh dashboard
  get '/dashboard/refresh' do
    load_app_details
    erb :'dashboard/refresh_js', :layout => false
  end
  
end