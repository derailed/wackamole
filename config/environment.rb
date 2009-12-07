# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'memcache'
memcache_options = {
 :c_threshold => 10_000,
 :compression => true,
 :debug       => false,
 :namespace   => "ia",
 :readonly    => false,
 :urlencode   => false
}
CACHE = MemCache.new( "localhost", memcache_options )

Rails::Initializer.run do |config|
  
  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  
  config.action_controller.session = {
    :session_key => '_wa_session',
    :cache       => CACHE,
    :expires     => 60*60*24,
    :secret      => 'bumble_bee_tuna'
  }
  config.action_controller.session_store = :mem_cache_store
    
  config.log_level = :debug
  
  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/lib/core_ext )

  config.middleware.use Rack::Reloader
  
  # Specify gems that this application depends on and have them installed with rake gems:install
  config.gem 'rackamole'
  config.gem 'mongo_mapper'
  
  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.  
  # BOZO !! Montain Time for me....
  config.time_zone = 'Mountain Time (US & Canada)'
end