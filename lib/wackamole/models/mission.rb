require 'forwardable'

module Wackamole
  class Mission
    extend ::SingleForwardable

    # -----------------------------------------------------------------------
    # Pick up moled application pulse
    def self.pulse( last_tick )
      zones = {}
      Wackamole::Control.zones.each do |zone|
        zones[zone] = {}
        Wackamole::Control.mole_databases( zone ).each do |db_name|
          db            = Wackamole::Control.db( zone, db_name )
          app_name, env = Wackamole::Control.extract_app_info( db_name )
          logs_cltn     = db['logs']
          
          zones[zone][app_name] = {} unless zones[zone][app_name]
          zones[zone][app_name][env] = {} unless zones[zone][app_name][env]
          
          zones[zone][app_name][env][:to_date]   = count_logs( logs_cltn )
          zones[zone][app_name][env][:today]     = count_logs( logs_cltn, last_tick, true )
          zones[zone][app_name][env][:last_tick] = count_logs( logs_cltn, last_tick )
        end
      end
      zones
    end
          
    # =========================================================================
    private

      # -----------------------------------------------------------------------
      # Compute mole counts for each moled apps
      def self.count_logs( logs_cltn, now=nil, single_day=false )
        conds  = gen_conds( now, single_day )
# puts conds.inspect        
        totals = { 
          Rackamole.feature => 0, 
          Rackamole.perf    => 0, 
          Rackamole.fault   => 0 
        }        
        [Rackamole.feature, Rackamole.perf, Rackamole.fault].each do |t|
          conds[:typ] = t
          totals[t] = logs_cltn.find( conds, :fields => [:_id] ).count
        end
        totals
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