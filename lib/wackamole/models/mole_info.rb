require 'benchmark'

module Wackamole
  class MoledInfo
  
    def self.logs_cltn()     Wackamole::Control.collection( 'logs' ) ;  end
    def self.users_cltn()    Wackamole::Control.collection( 'users' );  end
    def self.features_cltn() Wackamole::Control.collection( 'features' );  end  
                            
    # ---------------------------------------------------------------------------
    # Collect various data points to power up dashboard 
    # TODO - PERF - try just using cursor vs to_a
    def self.collect_dashboard_info( now )    
      info    = {}
      
      info[:total_users]    = users_cltn.count
      info[:total_features] = features_cltn.count
      info[:perf_load]      = 0
      info[:fault_load]     = 0
        
      # Fetch day logs          
      utc_time = now.clone.utc
puts utc_time      
      conds = SearchFilter.time_conds( now, 0 )
      day_logs = logs_cltn.find( conds, 
        :fields => [:typ, :fid, :tid, :did, :uid], 
        :sort => [ [:tid => Mongo::ASCENDING] ] )
puts conds.inspect
puts day_logs.count
      # Count all logs per hourly time period
      users         = Set.new
      features      = Set.new
      local_time    = now.clone.localtime
      hours         = (0...24).to_a
      hour_info     = hours.inject(OrderedHash.new) { |res,hour| res[hour] = { :user => 0, :feature => 0, :perf => 0, :fault => 0 };res }    
      user_per_hour = {}
      day_logs.each do |log|
        date_tokens = log['did'].match( /(\d{4})(\d{2})(\d{2})/ ).captures
        time_tokens = log['tid'].match( /(\d{2})(\d{2})(\d{2})/ ).captures        
        log_utc     = Time.utc( date_tokens[0], date_tokens[1], date_tokens[2], time_tokens[0], time_tokens[1], time_tokens[2] )
        local       = log_utc.clone.localtime
        hour        = local.hour
        
        next if hour > local_time.hour

        if log_utc.hour == utc_time.hour
          users    << log['uid']
          features << log['fid']
          info[:fault_load] += 1 if log['typ'] == Rackamole.fault
          info[:perf_load]  += 1 if log['typ'] == Rackamole.perf
        end
        
        if user_per_hour[hour]
          unless user_per_hour[hour].include? log['uid']
            hour_info[hour][:user] += 1
            user_per_hour[hour] << log['uid']
          end
        else
          user_per_hour[hour] = [ log['uid'] ]
          hour_info[hour][:user] += 1
        end
        case log['typ']
          when Rackamole.feature : hour_info[hour][:feature] += 1
          when Rackamole.perf    : hour_info[hour][:perf]    += 1
          when Rackamole.fault   : hour_info[hour][:fault]   += 1
        end
      end
                
      info[:user_load]    = users.size
      info[:feature_load] = features.size
      %w(user fault perf feature).each do |s|
        k = "#{s}_series".to_sym
        info[k] = []
        hour_info.values.map do |hash| 
          info[k] << hash[s.to_sym]
        end
      end
      info
    end        
  end
end