class ReportsController < ApplicationController
  
  layout 'landscape'

  # ---------------------------------------------------------------------------
  def index
    @old_reports = Report.find( {}, :sort => [ [:app, Mongo::ASCENDING], [:env, Mongo::ASCENDING] ] ).to_a
    last_tick = session[:last_tick] || 1.minute.ago.utc
    @reports = Report.find_reports( last_tick )
    session[:last_tick] = Time.now.utc
  end

  # ---------------------------------------------------------------------------
  # Refresh loop  
  def refresh
    render :update do |page|
      page.redirect_to :action => :index
    end
  end
  
  # ---------------------------------------------------------------------------
  # User says the issue if fixed. Clear out report and see what happens next...
  def fixed
    Report.fix_me( params[:db], params[:app], params[:env], params[:type] )
    
    render :update do |page|
      page.redirect_to :action => :index
    end
  end
  
end