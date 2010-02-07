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
      day_logs = logs_cltn.find( { :did => now.to_date_id.to_s }, 
        :fields => [:typ, :fid, :tid, :did, :uid], 
        :sort => [ [:tid => Mongo::ASCENDING] ] ).to_a
        
      # Fetch user count for this hour
      users = day_logs.inject( Set.new ) do |set,log| 
        set << log['uid'] if log['tid'] =~ /^#{"%02d" % now.hour}/
        set
      end
      info[:total_users] = users_cltn.count
      info[:user_load]   = users.size

      # Fetch features for this hour    
      features = day_logs.inject( Set.new ) do |set,log| 
        set << log['fid'].to_s if log['tid'] =~ /^#{"%02d" % now.hour}/
        set 
      end
      info[:total_features] = features_cltn.count
      info[:feature_load]   = features.size
    
      info[:perf_load] = day_logs.inject(0) do |count,log| 
        if log['tid'] =~ /^#{"%02d" % now.hour}/
          count += (log['typ'] == Rackamole.perf ? 1 : 0 ) 
        end
        count
      end
      info[:fault_load] = day_logs.inject(0) do |count,log| 
        if log['tid'] =~ /^#{"%02d" % now.hour}/
          count += (log['typ'] == Rackamole.fault ? 1 : 0 ) 
        end
        count
      end
    
      # Count all logs per hourly time period
      hours         = (0...24).to_a
      hour_info     = hours.inject(OrderedHash.new) { |res,hour| res[hour] = { :user => 0, :feature => 0, :perf => 0, :fault => 0 };res }    
      user_per_hour = {}
      day_logs.each do |log|
        date_tokens = log['did'].match( /(\d{4})(\d{2})(\d{2})/ ).captures
        time_tokens = log['tid'].match( /(\d{2})(\d{2})(\d{2})/ ).captures
        
        utc         = Time.utc( date_tokens[0], date_tokens[1], date_tokens[2], time_tokens[0], time_tokens[1], time_tokens[2] )
        local       = utc.localtime
        hour        = local.hour
        current_day = local.day
        next if local.day != current_day
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
          when Rackamole.feature : hour_info[hour][:feature] += 1 if features.add?( log['fid'])
          when Rackamole.perf    : hour_info[hour][:perf]    += 1
          when Rackamole.fault   : hour_info[hour][:fault]   += 1
        end
      end
        
      # BOZO !! LAME ASS...
      info[:user_series]    = []
      info[:fault_series]   = []
      info[:perf_series]    = []
      info[:feature_series] = []
      hour_info.values.map do |hash| 
        info[:user_series]    << hash[:user]
        info[:fault_series]   << hash[:fault]
        info[:perf_series]    << hash[:perf]
        info[:feature_series] << hash[:feature]
      end
      info
    end  
        
    # ===========================================================================
    private
        
      # -------------------------------------------------------------------------
      # Makes sure we have some indexes set
      # BOZO !! Create script to set these up ?
      def self.ensure_indexes
      end
  end
end