require 'will_paginate'
require 'ostruct'

class FeaturesController < ApplicationController
  
  layout 'base'
    
  # ---------------------------------------------------------------------------
  def index
    @features = Feature.paginate_top_features( @filter.to_conds, params[:page] ? params[:page].to_i : 1 )
  end
  
  # ---------------------------------------------------------------------------
  # Search top features
  def search
    begin
      @filter.search_terms = params[:search_filter][:search_terms]      
      @features = Feature.paginate_top_features( @filter.to_conds )
    rescue => boom
      flash.now[:error] = boom
    end
    render :filter
  end
  
  # ---------------------------------------------------------------------------
  # Filter top features
  def filter
    @filter.from_options( params[:filter] )
    @features = Feature.paginate_top_features( @filter.to_conds )
  end
  
end