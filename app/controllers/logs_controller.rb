require 'will_paginate/array'

class LogsController < ApplicationController
  layout 'plain'
  
  # ---------------------------------------------------------------------------
  # Homey...
  def index
    @logs = App.paginate_logs( @filter.to_conds, params[:page] ? params[:page].to_i : 1 )
  end
  
  # ---------------------------------------------------------------------------
  # Search logs - must specify a context ie ses: fred
  def search
    begin
      @filter.search_terms = params[:search_filter][:search_terms]      
      @logs = App.paginate_logs( @filter.to_conds )
    rescue => boom
      logger.error boom
      flash.now[:error] = boom
      @logs = [].paginate
    end
    
    render :filter
  end
  
  # ---------------------------------------------------------------------------
  # Fecth info about a particular log
  def show
    @log = App.logs.find_one( params[:id] )
    render :show, :layout => false 
  end
  
  # ---------------------------------------------------------------------------
  # Filter logs
  def filter
    @filter.from_options( params[:filter] )
    @logs = App.paginate_logs( @filter.to_conds )
  end
  
end