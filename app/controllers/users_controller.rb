require 'will_paginate'
require 'ostruct'

class UsersController < ApplicationController
  
  layout 'base'
    
  # ---------------------------------------------------------------------------
  def index
    @users = User.paginate_top_users( @filter.to_conds, params[:page] ? params[:page].to_i : 1 )
  end
  
  # ---------------------------------------------------------------------------
  # Search users
  def search
    begin
      @filter.search_terms = params[:search_filter][:search_terms]
      @users = User.paginate_top_users( @filter.to_conds )
    rescue => boom
      flash.now[:error] = boom
    end
    
    render :filter
  end
  
  # ---------------------------------------------------------------------------
  # Filters out user's list
  def filter
    @filter.from_options( params[:filter] )
    @users = User.paginate_top_users( @filter.to_conds )
  end
  
end