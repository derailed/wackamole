require 'forwardable'

module Wackamole
  class Mission
    extend ::SingleForwardable

    def self.rollups_cltn() @rollups ||= Wackamole::Control.collection( 'rollups', 'wackamole_mdb', :strict => false ); end  
  
    def_delegators :rollups_cltn, :find, :find_one
  
    # -------------------------------------------------------------------------
    # Allows user to clear out perf or fault state til the next tick...  
    def self.reset!( app, env, type )
      rollups_cltn.update( { :app => app }, { '$set' => { "envs.#{env}.#{type}" => 0 } } )
    end
      
    # -------------------------------------------------------------------------      
    # Clean up rollups. Check if mole_db is still around
    def self.clean_up!
      databases   = Wackamole::Control.mole_databases
      con         = Wackamole::Control.connection      
      rollups     = rollups_cltn.find( {} )
      delete_list = []
      rollups.each do |rollup|
        app       = rollup['app']
        envs_info = rollup[envs].keys
        envs_info.each do |env|
          db_name = Wackamole::Control.to_mole_db( app, env )
          delete_list << env unless databases.include?( db_name )
        end
        # if app is no longer around blow away the rollup
        if delete_list.size == envs_info.size
          rollups_cltn.remove( { :_id => rollup['_id'] } )
        else
          delete_list.each do |env| 
            rollup[envs].delete( env )
          end
          rollups_cltn.save( rollup, :safe => true ) unless delete_list.empty?
        end
      end
    end
    
    # -------------------------------------------------------------------------
    # Retrieve reports if any...  
    # BOZO !! Handle case where report is no longer valid - ie no mole db
    def self.rollups( now, reset )
      clean_up!
      rollups = comb_applications( now, reset )
      rollups.each_pair do |app_name, env_info|
        env_info[envs].each_pair do |env, info|
          info.each_pair do |mole_type, count|
            rollup    = rollups_cltn.find_one( { :app => app_name } )
            type_name = to_type_name( mole_type )
            if rollup
              rollup_info = rollup[envs]
              if rollup_info and rollup_info[env]
                (rollup_info[env][type_name] and !reset) ? rollup_info[env][type_name] += count : rollup_info[env][type_name] = count
              elsif rollup_info
                rollup_info[env] = { type_name => count }
              # else
              #   rollup_info[envs] = { env => { type_name => count } }
              end
              rollups_cltn.save( rollup, :safe => true )
            else
              row = { :app => app_name, envs => { env => { type_name => count } } }
              rollups_cltn.insert( row, :safe => true )
            end
          end
        end
      end
      find( {}, :sort => [ [:app, Mongo::ASCENDING], [:env, Mongo::ASCENDING] ] ).to_a
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
  
      # ---------------------------------------------------------------------------
      # Check moled apps status - reports any perf/excep that occurred since the 
      # last check
      def self.comb_applications( now, reset )     
        report = {}
        Wackamole::Control.mole_databases.each do |db_name|
          db = Wackamole::Control.db( db_name )
                         
          app_name, env = Wackamole::Control.extract_app_info( db_name )        
          totals        = analyse_logs( db, now, reset )
        
          if report[app_name]
            report[app_name][envs][env] = totals
          else
            report[app_name] = { envs => { env => totals } }
          end
        end
        report
      end
    
      # -------------------------------------------------------------------------
      # Report on possible application issues
      def self.amend_report( report, app_name, env, log )
        type = log['typ']
        
        if report[app_name]
          env_info = report[app_name][envs]
          if env_info[env]
            env_info[env][type] ? env_info[env][type] += 1 : env_info[env][type] = 1
          else
            env_info[ env ] = { type => 1 }
          end
        else
          report[app_name] = { envs => { env => { type => 1 } }  } 
        end
      end    

      # -------------------------------------------------------------------------
      # envs key
      def self.envs() @envs ||= 'envs'; end
        
      # -------------------------------------------------------------------------        
      # computes counts for each mole types
      def self.analyse_logs( db, now, reset )
        check_types = [Rackamole.perf, Rackamole.fault, Rackamole.feature]
        date_id     = now.to_date_id.to_s
        time_id     = now.to_time_id
      
        if reset
          conds = {
            :did => date_id,
            :typ => { '$in'  => check_types }
          }
        else
          conds = {
            :did => { '$gte' => date_id },
            :tid => { '$gte' => time_id },
            :typ => { '$in'  => check_types }
          }
        end        

        logs   = db['logs'].find( conds, :fields => ['typ', 'rti', 'fault', 'fid'] )
        totals = 
        { 
          Rackamole.feature  => 0, 
          Rackamole.perf     => 0, 
          Rackamole.fault    => 0 
        }
        logs.each { |log| totals[log['typ']] += 1 }
        totals
      end
   end   
end