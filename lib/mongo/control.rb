require 'mongo'

puts "!!!!!!!!!!!!!!!!!!!!! Loading mongo control !!!!!!!!!!!!!!!!"

module Mongo
  class Control
    
    # Collection accessors...
    # def logs_cltn()     @logs     ||= db.collection( 'logs' );  end  
    # def users_cltn()    @users    ||= db.collection( 'users' );    end
    # def features_cltn() @features ||= db.collection( 'features' ); end
      
    # ---------------------------------------------------------------------------
    # Fetch a collection on a given database by name
    def self.collection( cltn_name, db_name=nil )
      RAILS_DEFAULT_LOGGER.debug "Looking for cltn - #{cltn_name} on DB #{db_name}"
      reset_db!( db_name ) if db_name
      cltn = db.collection( cltn_name )
      RAILS_DEFAULT_LOGGER.debug "Fetched collection #{cltn_name} on #{@db.name}"
      cltn
    end
  
    # ---------------------------------------------------------------------------
    # Switch db instance given db_name 
    # NOTE : This assumes mole db naming convention 
    # ie mole_{app_name in lower case}_{env}_mdb
    def self.switch_db!( app_name, env )
      app = app_name.gsub( /\s/, '_' ).downcase
      db_name = "mole_%s_%s_mdb" % [app, env]
      
      reset_db!( db_name )
      @db.name
    end
  
    # ---------------------------------------------------------------------------
    # Ensures we have the right db connection
    def self.reset_db!( db_name )
      @db = nil
      db( db_name )
    end
  
    # -------------------------------------------------------------------------
    # Retrieves a db from the connection
    def self.get_database( db_name )
      connection.db( db_name )
    end
    
    # -------------------------------------------------------------------------
    # Inspect current connection databases and weed out mole_xxx databases
    def self.mole_databases
      connection.database_names.select{ |db| db if db =~ /^mole_/ }
    end
  
    # ===========================================================================
    private
  
      # ---------------------------------------------------------------------------
      # Initialize app by reading off mongo configuration parameters if necessary
      def self.config
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
      def self.connection
        @connection ||= Mongo::Connection.new( config['host'], config['port'] ) #, :logger => RAILS_DEFAULT_LOGGER )
      end      
  
      # ---------------------------------------------------------------------------
      # Fetch database instance
      def self.db( db_name=nil, opts={:strict => false} )
        RAILS_DEFAULT_LOGGER.debug "DB #{db_name.inspect} -- current #{@db ? @db.name : 'N/A'} --- #{opts.inspect}"        
        return @db if @db
        @db = connection.db( db_name, opts )
        RAILS_DEFAULT_LOGGER.debug "CONNECTING TO DB #{@db.name}"        
        ensure_indexes
        @db
      end  
    
      # -------------------------------------------------------------------------
      # Make sure the right indexes are set
      def self.ensure_indexes
      end
  end
end