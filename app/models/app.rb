require 'benchmark'

class App

  # Collection accessors...
  def self.logs_cltn()     @logs     ||= db.collection( 'logs' );     end
  def self.users_cltn()    @users    ||= db.collection( 'users' );    end
  def self.features_cltn() @features ||= db.collection( 'features' ); end
  
  # Pagination size
  def self.default_page_size() @page_size ||= 20; end

  # ---------------------------------------------------------------------------
  # Find the app name and env for the features collection
  # NOTE: Assumes 1 moled app per db...
  def self.get_app_info
    feature = features_cltn.find_one( {}, :fields => [:app, :env] )
    return feature['app'], feature['env']
  end
    
  # ---------------------------------------------------------------------------
  # Initialize app by reading off mongo configuration parameters if necessary
  def self.config
    unless @config
      begin
        config_file = File.join( RAILS_ROOT, %w[config mongo.yml] )
        config      = YAML.load_file( config_file )
        @config     = config[RAILS_ENV]
      rescue => boom
        $stderr.puts "Rackamole init error - #{boom}"
        raise "Hoy? Unable to locate mongo config file in `#{config_file}. Did you copy and update config/default_mongo.yml?" unless config
      end
    end
    @config
  end

  # ---------------------------------------------------------------------------
  # Paginate top features
  def self.paginate_top_features( conds, page=1 )
    tops    = []    
    elapsed = Benchmark::realtime do
      tops = logs_cltn.group( [:fid], conds, { :count => 0 }, 'function(obj,prev) { prev.count += 1}', true )
    end
    puts "PERF - Top features %d -- %3.2f" % [tops.size, elapsed]
    
    features = []
    tops.sort{ |a,b| b['count'] <=> a['count'] }.each do |row|
      features << { :fid => row['fid'], :total => row['count'].to_i }
    end
    
    WillPaginate::Collection.create( page, default_page_size, features.size ) do |pager|      
      offset = (page-1)*default_page_size
      result = features[offset...(offset+default_page_size)]
      result.each do |u|
        feature = features_cltn.find_one( Mongo::ObjectID.from_string(u[:fid]) )
        u[:name] = feature
      end
      pager.replace( result )
    end
  end
          
  # ---------------------------------------------------------------------------
  # Paginate top users
  def self.paginate_top_users( conds, page=1 )
    tops    = []    
    elapsed = Benchmark::realtime do
      tops = logs_cltn.group( [:uid], conds, { :count => 0 }, 'function(obj,prev) { prev.count += 1}', true )
    end
    puts "PERF - Top users %d -- %3.2f" % [tops.size, elapsed]
    
    users = []
    tops.sort{ |a,b| b['count'] <=> a['count'] }.each do |row|
      users << { :uid => row['uid'], :total => row['count'].to_i, :details => [] }
    end
    
    WillPaginate::Collection.create( page, default_page_size, users.size ) do |pager|      
      offset = (page-1)*default_page_size
      result = users[offset...(offset+default_page_size)]
      result.each do |u|
        user = users_cltn.find_one( Mongo::ObjectID.from_string(u[:uid]), :fields => [:una] )
        u[:name] = user['una']
      end
      pager.replace( result )
    end
  end
        
  # ---------------------------------------------------------------------------
  # Fetch pagination collection for given condition
  def self.paginate_logs( conds, page=1 )    
    matching = logs_cltn.find( conds )    
    WillPaginate::Collection.create( page, default_page_size, matching.count ) do |pager|
      pager.replace( logs_cltn.find( conds, 
        :sort  => [ ['did', 'desc'], ['tid', 'desc'] ],
        :skip  => (page-1)*default_page_size, 
        :limit => default_page_size ).to_a )
    end
  end
            
  # ---------------------------------------------------------------------------
  # Collect various data points to power up dashboard 
  # TODO - PERF - try just using cursor vs to_a
  def self.collect_dashboard_info( now )    
    info    = {}
    day_logs = []
    elapsed = Benchmark::realtime do
      day_logs = logs_cltn.find( { :did => now.to_date_id.to_s }, :fields => [:typ, :fid, :tid, :did, :uid] ).to_a
    end
    puts "Time to find logs - %d -- %4.2f" % [day_logs.size, elapsed]
    
    # Fetch user count for this hour
    users = day_logs.inject( Set.new ) do |set,log| 
      set << log['uid'] if log['tid'] =~ /^#{"%02d" % now.hour}/
      set
    end
    info[:total_users] = users_cltn.count
    info[:user_load]   = users.size

    # Fetch features for this hour    
    features = day_logs.inject( Set.new ) do |set,log| 
      set << log['fid'] if log['tid'] =~ /^#{"%02d" % now.hour}/
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
    times         = (0...24).to_a
    time_info     = times.inject(OrderedHash.new) { |res,time| res[time] = { :user => 0, :feature => 0, :perf => 0, :fault => 0 };res }    
    user_per_hour = {}
    day_logs.each do |log|
      date_tokens = log['did'].match( /(\d{4})(\d{2})(\d{2})/ ).captures
      time_tokens = log['tid'].match( /(\d{2})(\d{2})(\d{2})/ ).captures    
      utc         = Time.utc( date_tokens[0], date_tokens[1], date_tokens[2], time_tokens[0], time_tokens[1], time_tokens[2] )
      time        = utc.getlocal.hour
      if user_per_hour[time]
        unless user_per_hour[time].include? log['uid']
          time_info[time][:user] += 1
          user_per_hour[time] << log['uid']
        end
      else
        user_per_hour[time] = [ log['uid'] ]
        time_info[time][:user] += 1
      end
      case log['typ']
        when Rackamole.feature : time_info[time][:feature] += 1
        when Rackamole.perf    : time_info[time][:perf]    += 1
        when Rackamole.fault   : time_info[time][:fault]   += 1
      end
    end
        
    # BOZO !! LAME ASS...
    info[:user_series]    = []
    info[:fault_series]   = []
    info[:perf_series]    = []
    info[:feature_series] = []
    time_info.values.map do |hash| 
      info[:user_series]    << hash[:user]
      info[:fault_series]   << hash[:fault]
      info[:perf_series]    << hash[:perf]
      info[:feature_series] << hash[:feature]
    end    
    info
  end  
  
  # ---------------------------------------------------------------------------
  # Check moled apps status - reports any perf/excep that occurred since the 
  # last check
  def self.comb( now )
    report      = {}
    check_types = [Rackamole.perf, Rackamole.fault]
    date_id     = now.to_date_id.to_s
    time_id     = now.to_time_id
    conds       = {
      :did => { '$gte' => date_id },
      # :tid => { '$gte' => time_id },
      :typ => { '$in'  => check_types }
    }
puts conds.inspect    
    mole_databases.each do |db_name|
puts "Checking #{db_name}"      
      db = connection.db( db_name )      
      logs = db['logs'].find( conds, :fields => ['typ', 'rti', 'fault', 'fid'] )
        
      # Oh dear - someting happened here - report it!
      if logs.count > 0
puts "Found something #{logs.count}"
        feature_id = nil
        logs.each do |log|
          unless feature_id
            feature_id = log['fid'].instance_of?(String) ? Mongo::ObjectID.from_string( log['fid'] ) : log['fid']
          end
          feature = db['features'].find_one( { '_id' => feature_id }, :fields => ['app', 'env'] )
          
          amend_report( report, feature, log, log['typ'] )
        end
      end
    end
    report
  end
  
  # ===========================================================================
  private
  
    # -------------------------------------------------------------------------
    # Report on possible application issues
    def self.amend_report( report, feature, log, type )
      app_name         = feature['app']
      env              = feature['env']
      info             = { :type => log['typ'], :count => 0 }
      
      if report[app_name]
        if report[app_name][env]
          report[app_name][env][type] ? report[app_name][env][type] += 1 : report[app_name][env][type] = 1
        else
          report[app_name][ env ] = { type => 1 }
        end
      else
        report[app_name] = { env => { type => 1 }  } 
      end
    end
    
    # ---------------------------------------------------------------------------
    # Inspect current connection databases and weed out mole_xxx databases
    def self.mole_databases
      connection.database_names.select{ |db| db if db =~ /^mole_/ }
    end
  
    # Connects to mongo instance if necessary...
    def self.connection
      @connection ||= Mongo::Connection.new( config['host'], config['port'] ) #, :logger => RAILS_DEFAULT_LOGGER )
    end

    # Fetch database instance    
    def self.db
      return @db if @db
      @db = connection.db( config['database'] )
      ensure_indexes
      @db
    end
  
    # Makes sure we have some indexes set
    # BOZO !! Create script to set these up ?
    def self.ensure_indexes
      logs_cltn.create_index( :fid )
      logs_cltn.create_index( :uid )
      logs_cltn.create_index( :did )
      logs_cltn.create_index( :tid )
      logs_cltn.create_index( [ [:did, Mongo::DESCENDING], [:tid, Mongo::DESCENDING] ] )
      users_cltn.create_index( :una )
      features_cltn.create_index( :ctx )
      features_cltn.create_index( [ [:ctl, Mongo::ASCENDING], [:act, Mongo::ASCENDING] ] )
    end
end