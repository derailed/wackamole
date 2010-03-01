require 'mongo'
require 'logger'

module Wackamole
  class Control

    # -----------------------------------------------------------------------
    # Initialize app by reading off mongo configuration parameters if necessary
    def self.init_config( config_file, env )
      begin
        config  = YAML.load_file( config_file )        
        @config = config[env]
        raise "Invalid environment `#{env}" unless @config
        raise "Unable to find host in - #{@config.inspect}" unless @config.has_key?('host')
        raise "Unable to find port in - #{@config.inspect}" unless @config.has_key?('port')            
      rescue => boom
        @config = nil          
        raise "Hoy! An error occur loading the config file `#{config_file} -- #{boom}"
      end
      @config
    end
    
    # -------------------------------------------------------------------------
    # Defines mole db identity      
    def self.molex() @molex || /mole_(.*)?_(.*)?_mdb/; end
        
    # -------------------------------------------------------------------------
    # Fetch a collection on a given database by name
    def self.collection( cltn_name, db_name=nil, opts={:strict => true} )
      # reset_db!( db_name ) if db_name
      db( db_name, opts ).collection( cltn_name )
    end
      
    # -------------------------------------------------------------------------
    # extract app_name + env from db_name
    def self.extract_app_info( db_name )
      raise "Invalid mole db specification #{db_name}" unless db_name =~ molex
      db_name.match( molex ).captures
    end
      
    # -------------------------------------------------------------------------
    # Switch db instance given db_name 
    # NOTE : This assumes mole db naming convention 
    # ie mole_{app_name in lower case}_{env}_mdb
    def self.switch_mole_db!( app_name, env )
      raise "You must specify an app name and environment" unless app_name and env      
      app = app_name.gsub( /\s/, '_' ).downcase
      db_name = to_mole_db( app_name, env )
      raise "Invalid mole database #{db_name}" unless mole_db?( db_name )      
      reset_db!( db_name )
      @db
    end
    
    # -------------------------------------------------------------------------
    # Inspect current connection databases and weed out mole_xxx databases
    def self.mole_databases
      connection.database_names.select do |db_name|
        db_name if mole_db?( db_name )
      end
    end
  
    # =========================================================================
    private
  
      # -----------------------------------------------------------------------
      # Computes mole_db name from app and env
      def self.to_mole_db( app_name, env )
        "mole_%s_%s_mdb" % [app_name, env] 
      end
      
      # -----------------------------------------------------------------------
      # Reset connection. For testing only!
      def self.reset!
        @connection.close if @connection
        @connection = nil
        @config     = nil
      end

      # -----------------------------------------------------------------------
      # Checks if this is a mole database  
      def self.mole_db?( db_name )
        return false unless db_name =~ molex
        db    = connection.db( db_name )
        db.authenticate( config['username'], config['password'] )
        cltns = db.collection_names
        return ((%w[users features logs] & cltns).size == 3)
      end
      
      # -----------------------------------------------------------------------
      # Ensures we have the right db connection
      def self.reset_db!( db_name )
        return if @db and @db.name == db_name
        @db = nil
        db( db_name )
      end
      
      def self.config
        raise "You must call init_config before using this object" unless @config
        @config
      end
    
      #
      def self.single_app?
        config['db_name']
      end
      
      #
      def self.app_info
        if config['db_name']
          return extract_app_info( config['db_name'] )
        end
        nil
      end
      
      # -----------------------------------------------------------------------
      # Connects to mongo instance if necessary...
      def self.connection( log=false )
        logger = nil
        if log
          logger       = Logger.new($stdout)
          logger.level = Logger::DEBUG
        end
        @connection ||= Mongo::Connection.new( config['host'], config['port'], :logger => logger )
      end      
  
      # -----------------------------------------------------------------------
      # Fetch database instance
      def self.db( db_name=nil, opts={:strict => true} ) 
        return @db if @db and !db_name
        return @db if @db and @db.name == db_name
        raise "No database specified" unless db_name
        @db = connection.db( db_name, opts )
      end  
    
      # -----------------------------------------------------------------------
      # Make sure the right indexes are set
      def self.ensure_indexes!( set=true, drop_first=false, show_info=false, clear_only=false )
        mole_databases.each do |db_name|
          db = db( db_name )
          
          puts "-"*100
          puts "Database - #{db_name}"
          
          if drop_first or clear_only
            puts "[WARNING] Dropping indexes on all Rackamole collections"
            %w(logs features users).each do |c|            
              db[c].drop_indexes
            end            
          end
          
          if set and !clear_only
            puts "[INFO] Creating indexes on all Rackamole collections..."
            Wackamole::Log.ensure_indexes!
            Wackamole::Feature.ensure_indexes!
            Wackamole::User.ensure_indexes!
          end
                       
          if show_info
            %w(logs features users).each do |c|
              indexes = db[c].index_information
              puts "\tIndexes on collection `#{c}"
              indexes.keys.sort.each { |k| puts "\t\tIndex: %-30s -- %s" % [k,indexes[k].join( ", ")] }
            end
          end
        end
      end
  end
end