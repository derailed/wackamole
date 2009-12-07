require 'will_paginate'
require 'ostruct'

class UsersController < ApplicationController
  layout 'plain'
  
  # ---------------------------------------------------------------------------
  def index
    @users = App.paginate_top_users( @filter.to_conds, params[:page] ? params[:page].to_i : 1 )
  end
  
  # ---------------------------------------------------------------------------
  # Search users
  def search
    begin
      @filter.search_terms = params[:search_filter][:search_terms]
      @users = App.paginate_top_users( @filter.to_conds )
    rescue => boom
      flash.now[:error] = boom
    end
    
    render :filter
  end
  
  # ---------------------------------------------------------------------------
  def filter
    @filter.from_options( params[:filter] )
    @users = App.paginate_top_users( @filter.to_conds )
  end
  
end