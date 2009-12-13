class Report < Base

  def self.find( selector, opts={} )
    reports_cltn.find( selector, opts )
  end
  
  def self.fix_me( db, app, env, type )
    reports_cltn.update( { :db => db, :app => app }, { '$set' => { "envs.#{env}.#{type}" => 0 } } )
  end
  
  # ---------------------------------------------------------------------------
  # Retrieve reports if any...  
  def self.find_reports( now )
    reports = comb_applications( now )
    reports.each_pair do |app_name, env_info|
      db_name = env_info[:db]
      
      env_info[:envs].each_pair do |env, info|
        info.each_pair do |type, count|
          report = reports_cltn.find_one( { :app => app_name } )      

          type_name = to_type_name( type )
                    
          if report
            envs = report['envs']
            if envs and envs[env]
              envs[env][type_name] ? envs[env][type_name] += count : envs[env][type_name] = count
              report['envs'] = envs
            elsif envs
              report['envs'][env] = {type_name => count }
            else
              report['envs'] = { env => {type_name => count } }
            end
            reports_cltn.save( report, :safe => true )
          else
            row = { :app => app_name, :db => db_name, :envs => { env => { type_name => count } } }
            reports_cltn.insert( row, :safe => true )
          end
        end
      end
    end
    reports_cltn.find( {}, :sort => [ [:app, Mongo::ASCENDING], [:env, Mongo::ASCENDING] ] )
  end
  
  # ===========================================================================
  private

    # -------------------------------------------------------------------------
    # Inspect current connection databases and weed out mole_xxx databases
    def self.mole_databases
      connection.database_names.select{ |db| db if db =~ /^mole_/ }
    end

    # -------------------------------------------------------------------------
    # Map rackamole types to report types  
    def self.to_type_name( type )
      case type
        when Rackamole.perf  : "perfs"
        when Rackamole.fault : "faults"
        else                   "features"
      end
    end
  
    # ---------------------------------------------------------------------------
    # Check moled apps status - reports any perf/excep that occurred since the 
    # last check
    def self.comb_applications( now )
      report       = {}
     
      check_types = [Rackamole.perf, Rackamole.fault, Rackamole.feature]
      date_id     = now.to_date_id.to_s
      time_id     = now.to_time_id
      conds       = {
        :did => { '$gte' => date_id },
        :tid => { '$gte' => time_id },
        :typ => { '$in'  => check_types }
      }

      mole_databases.each do |db_name|
        db      = connection.db( db_name )      
        logs    = db['logs'].find( conds, :fields => ['typ', 'rti', 'fault', 'fid'] )
        feature = db['features'].find_one( {}, :fields => ['app', 'env'] )
          
        if logs.count > 0
          logs.each { |log| amend_report( report, db_name, feature, log, log['typ'] ) }
        else
          if feature
            unless report[feature['app']]
              report[feature['app']] = {
                :db   => db_name,
                :envs => { feature['env'] => { Rackamole.feature => 0, Rackamole.perf => 0, Rackamole.fault => 0 } }
              }
            else
              report[feature['app']][:envs][feature['env']] = { Rackamole.feature => 0, Rackamole.perf => 0, Rackamole.fault => 0 }
            end
          end
        end
      end
      report
    end
    
    # -------------------------------------------------------------------------
    # Report on possible application issues
    def self.amend_report( report, db_name, feature, log, type )
      app_name         = feature['app']
      env              = feature['env']
      info             = { :type => log['typ'], :count => 0 }
      
      if report[app_name]
        if report[app_name][:envs][env]
          report[app_name][:envs][env][type] ? report[app_name][:envs][env][type] += 1 : report[app_name][:envs][env][type] = 1
        else
          report[app_name][:envs][ env ] = { type => 1 }
        end
      else
        report[app_name] = { :db => db_name.to_s, :envs => { env => { type => 1 } }  } 
      end
    end

    # ---------------------------------------------------------------------------
    # Retrieve or create report db and collection
    def self.reports_cltn
      @reports_cltn ||= db.collection( 'reports' )
    end
  
    # -------------------------------------------------------------------------
    # Fetch database instance    
    def self.db
      return @db if @db
      @db = connection.db( 'reports_mdb' )
    end
    
end