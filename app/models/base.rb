class Base
  
  # ===========================================================================
  protected
  
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

    # Connects to mongo instance if necessary...
    def self.connection
      @connection ||= Mongo::Connection.new( config['host'], config['port'] ) #, :logger => RAILS_DEFAULT_LOGGER )
    end
      
end