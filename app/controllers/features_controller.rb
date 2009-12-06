require 'will_paginate'
require 'ostruct'

class FeaturesController < ApplicationController
  layout 'plain'
  
  # ---------------------------------------------------------------------------
  def index
    top_features
  end
  
  # ---------------------------------------------------------------------------
  # Search top features
  def search
    @filter.search_terms = params[:search_filter][:search_terms]
    begin
      conds = @filter.to_conds
    rescue => boom
      logger.error boom
      # No match flash it
      flash.now[:error] = boom
    end
    top_features 
    render :filter
  end
  
  # ---------------------------------------------------------------------------
  # Filter top features
  def filter
    @filter.from_options( params[:filter] )
    top_features
  end
  
  # ===========================================================================
  private
  
    # -------------------------------------------------------------------------
    # Fetch top features
    def top_features
      tops    = []    
      elapsed = Benchmark::realtime do
        tops = Log.find_top_features( @filter )
      end
      logger.info "PERF - Top features %d -- %3.2f" % [tops.size, elapsed]

      features = []
      tops.sort{ |a,b| b['count'] <=> a['count'] }.each do |row|
        features << { :fid => row['fid'], :total => row['count'].to_i, :details => [] }
      end
    
      per_page     = 15
      current_page = params[:page] ? params[:page].to_i : 1
      @features = WillPaginate::Collection.create( current_page, per_page, features.size ) do |pager|
        offset = (current_page-1)*per_page
        result = features[offset...(offset+per_page)]
        result.each do |f|          
          feature = Feature.find( f[:fid], :fields => [:act, :ctl, :ctx] )
          f[:name] = feature.context
        end
        pager.replace( result )
      end
    end      
end