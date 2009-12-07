require 'rackamole'
require 'core_ext/time'

class DashController < ApplicationController
  
  layout 'plain'

  # ---------------------------------------------------------------------------
  # Refresh loop  
  def refresh
    render :update do |page|
      page.redirect_to :action => :index
    end
  end
  
  # ---------------------------------------------------------------------------
  # Home sweet home  
  def index
    now = @updated_on.utc  
    @info = App.collect_dashboard_info( now )
  end
end