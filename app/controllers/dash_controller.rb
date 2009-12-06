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
    
    day_logs = []
    elapsed = Benchmark::realtime do
      day_logs = Log.find( :all, 
        :conditions => { :did => now.to_date_id.to_s }, 
        :fields => [:typ, :fid, :tid, :did, :uid] )
    end
    puts "Time to find logs - %d -- %4.2f" % [day_logs.size, elapsed]
    
    # Fetch user count for this hour
    users = day_logs.inject( Set.new ) do |set,log| 
      set << log['uid'] if log['tid'] =~ /^#{"%02d" % now.hour}/
      set
    end
    @total_users = User.collection.count
    @user_load   = users.size

    # Fetch features for this hour    
    features = day_logs.inject( Set.new ) do |set,log| 
      set << log['fid'] if log['tid'] =~ /^#{"%02d" % now.hour}/
      set 
    end
    @total_features = Feature.collection.count
    @feature_load   = features.size
    
    @perf_load = day_logs.inject(0) do |count,log| 
      if log['tid'] =~ /^#{"%02d" % now.hour}/
        count += (log['typ'] == Rackamole.perf ? 1 : 0 ) 
      end
      count
    end
    @fault_load = day_logs.inject(0) do |count,log| 
      if log['tid'] =~ /^#{"%02d" % now.hour}/
        count += (log['typ'] == Rackamole.fault ? 1 : 0 ) 
      end
      count
    end
    
    # Count all logs per hourly time period
    times = (0...24).to_a
    info = times.inject(OrderedHash.new) { |res,time| res[time] = { :user => 0, :feature => 0, :perf => 0, :fault => 0 };res }
    
    user_per_hour = {}
    day_logs.each do |log|
      date_tokens = log['did'].match( /(\d{4})(\d{2})(\d{2})/ ).captures
      time_tokens = log['tid'].match( /(\d{2})(\d{2})(\d{2})/ ).captures    
      utc         = Time.utc( date_tokens[0], date_tokens[1], date_tokens[2], time_tokens[0], time_tokens[1], time_tokens[2] )
      time        = utc.getlocal.hour
      if user_per_hour[time]
        unless user_per_hour[time].include? log['uid']
          info[time][:user] += 1
          user_per_hour[time] << log['uid']
        end
      else
        user_per_hour[time] = [ log['uid'] ]
        info[time][:user] += 1
      end
      case log['typ']
        when Rackamole.feature : info[time][:feature] += 1
        when Rackamole.perf    : info[time][:perf]    += 1
        when Rackamole.fault   : info[time][:fault]   += 1
      end
    end
        
    # BOZO !! LAME ASS...
    @user_series    = []
    @fault_series   = []
    @perf_series    = []
    @feature_series = []
    info.values.map do |hash| 
      @user_series    << hash[:user]
      @fault_series   << hash[:fault]
      @perf_series    << hash[:perf]
      @feature_series << hash[:feature]
    end
  end
end