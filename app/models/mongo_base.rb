module MongoBase    
  
  # Collection accessors...
  def logs_cltn()     @logs     ||= db.collection( 'logs' );  end  
  def users_cltn()    @users    ||= db.collection( 'users' );    end
  def features_cltn() @features ||= db.collection( 'features' ); end
  
  # ---------------------------------------------------------------------------
  # Ensures we have the right db connection
  def current_db( db_name )
    db( db_name )
    self
  end
  
  # ---------------------------------------------------------------------------
  # Initialize app by reading off mongo configuration parameters if necessary
  def config
    unless @config
      begin
        config_file = File.join( RAILS_ROOT, %w[config mongo.yml] )
        config      = YAML.load_file( config_file )
        @config     = config[RAILS_ENV]
      rescue => boom
        $stderr.puts "Wackamole init error - #{boom}"
        raise "Hoy? Unable to locate mongo config file in `#{config_file}. Did you copy and update config/default_mongo.yml?" unless config
      end
    end
    @config
  end

  # ---------------------------------------------------------------------------
  # Connects to mongo instance if necessary...
  def connection
    @connection ||= Mongo::Connection.new( config['host'], config['port'] ) #, :logger => RAILS_DEFAULT_LOGGER )
  end      
  
  # ---------------------------------------------------------------------------
  # Fetch database instance
  def db( db_name=nil, opts={:strict => true} )
    return @db if @db
    @db = connection.db( db_name||config['database'], opts )
    ensure_indexes
    @db
  end
  
  # ---------------------------------------------------------------------------
  # Make sure the correct indexes are in place. 
  # Must be overriden by extended classes
  def ensure_indexes
  end
end