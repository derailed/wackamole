require 'forwardable'

module Wackamole
  class Mission
    extend ::SingleForwardable

    # -----------------------------------------------------------------------
    # Pick up moled application pulse
    def self.pulse( last_tick )
      count_to_date   = count_logs
      count_today     = count_logs( last_tick, true )
      count_last_tick = count_logs( last_tick )
      { :to_date => count_to_date, :today => count_today, :last_tick => count_last_tick }      
    end
    
    # -----------------------------------------------------------------------      
    # generates mole logs conditons
    def self.gen_conds( now, single_day )      
      conds = {}
      if now
        if single_day
          conds = SearchFilter.time_conds( now, 0 )
        else
          now = now.clone.utc
          date_id     = now.to_date_id.to_s
          time_id     = now.to_time_id
          conds[:did] = { '$gte' => date_id }
          conds[:tid] = { '$gte' => time_id }
        end
      end
      conds
    end
    
    # -----------------------------------------------------------------------
    # Compute mole counts for each moled apps
    def self.count_logs( now=nil, single_day=false )
      counts = {}
      conds  = gen_conds( now, single_day )

      Wackamole::Control.mole_databases.each do |db_name|
        db            = Wackamole::Control.db( db_name )
        app_name, env = Wackamole::Control.extract_app_info( db_name )
        logs_cltn     = db['logs']
        
        totals = { Rackamole.feature => 0, Rackamole.perf => 0, Rackamole.fault => 0 }
        if counts[app_name]
          counts[app_name][env] = totals
        else
          counts[app_name] = { env => totals }
        end
        row = counts[app_name][env]
        [Rackamole.feature, Rackamole.perf, Rackamole.fault].each do |t|
          conds[:typ] = t
          logs  = logs_cltn.find( conds, :fields => [:_id] )
          row[t] = logs.count
        end
      end
      counts
    end
      
    # =========================================================================
    private

      # -----------------------------------------------------------------------
      # Map rackamole types to report types  
      def self.to_type_name( type )
        case type
          when Rackamole.perf
            "perfs"
          when Rackamole.fault
            "faults"
          when Rackamole.feature
            "features"
          else
            raise "Invalid mole log type `#{type}"
        end
      end
   end   
end