require 'will_paginate'
require 'ostruct'

class UsersController < ApplicationController
  layout 'plain'
  
  # ---------------------------------------------------------------------------
  # BOZO !! Probem no current way to paginate group unless using map/reduce 
  # and store it in a collection. + Not sure what fields are being used on finder ??
  def index
    top_users
  end
  
  # ---------------------------------------------------------------------------
  # Search users
  def search
    @filter.search_terms = params[:search_filter][:search_terms]
    begin
      conds = @filter.to_conds
    rescue => boom
      logger.error boom
      # No match flash it
      flash.now[:error] = boom
    end
    top_users    
    render :filter
  end
  
  # ---------------------------------------------------------------------------
  def filter
    @filter.from_options( params[:filter] )
    top_users
  end
  
  # ===========================================================================
  private
  
    # -------------------------------------------------------------------------
    # Fetch top users
    def top_users
      tops    = []    
      elapsed = Benchmark::realtime do
        tops = Log.find_top_users( @filter )
      end
      logger.info "PERF - Top users %d -- %3.2f" % [tops.size, elapsed]

      users = []
      tops.sort{ |a,b| b['count'] <=> a['count'] }.each do |row|
        users << { :uid => row['uid'], :total => row['count'].to_i, :details => [] }
      end
    
      per_page     = 15
      current_page = params[:page] ? params[:page].to_i : 1
      @users = WillPaginate::Collection.create( current_page, per_page, users.size ) do |pager|
        offset = (current_page-1)*per_page
        result = users[offset...(offset+per_page)]
        result.each do |u|
          user = User.find( u[:uid], :fields => [:una] )
          u[:name] = user['una']
        end
        pager.replace( result )
      end
    end      
end