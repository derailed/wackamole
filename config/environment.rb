# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')


Rails::Initializer.run do |config|
  
  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
      
  config.log_level = :info
  
  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/lib/core_ext )
  
  # Specify gems that this application depends on and have them installed with rake gems:install
  config.gem "mongo"  
  # config.gem "mongo_ext", :lib => 'mongo_ext'
  config.gem "rackamole"
  config.gem "will_paginate"
  
  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.  
  # BOZO !! Montain Time for me....
  config.time_zone = 'Mountain Time (US & Canada)'
end