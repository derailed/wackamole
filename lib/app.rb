require 'rubygems'
require 'sinatra'
require 'forwardable'
require 'mongo'
gem     'agnostic-will_paginate'
require 'will_paginate'
require 'mongo_rack'
require 'rackamole'
require File.expand_path( File.join( File.dirname(__FILE__), 'wackamole.rb' ) )

set :public, File.join( File.dirname(__FILE__), %w[.. public] )
set :views , File.join( File.dirname(__FILE__), %w[.. views] )

def default_config
  File.join( ENV['HOME'], %w[.wackamole wackamole.yml] )    
end

# -----------------------------------------------------------------------------
# Configurations

configure :production do
  set :logging, false  
end

configure do
  set :sessions, false
    
  Wackamole.load_all_libs_relative_to(__FILE__, 'helpers' )
  Wackamole.load_all_libs_relative_to(__FILE__, 'controllers' )
 
  #Pick up command line args if any?  
  if defined? @@options and @@options
    if @@options[:protocol] == 'mongo'
      use Rack::Session::Mongo, 
        :server => "%s:%d/%s/%s" % [@@options[:host], @@options[:port], @@options[:db_name], @@options[:cltn_name]]
    else
      use Rack::Session::Memcache, 
        :memcache_server => "%s:%d" % [@@options[:host], @@options[:port]],
        :namespace       => @@options[:namespace]
    end
  else
    # Default is a mongo session store
    use Rack::Session::Mongo, :server => "%s:%d/%s/%s" % ['localhost', '27017', 'wackamole_ses', 'sessions']
  end  
  set :con, Wackamole::Control.init_config( default_config, Sinatra::Application.environment.to_s )
end

# -----------------------------------------------------------------------------
# Before filters
before do
  unless request.path =~ /\.[css gif png js]/
    @filter = session[:filter]
    unless @filter
      @filter = Wackamole::SearchFilter.new
      session[:filter] = @filter
    end
    @updated_on   = Time.now
    @refresh_rate = 15
    
    @app_info     = session[:app_info]
    Wackamole::Control.switch_mole_db!( @app_info[:app_name].downcase, @app_info[:stage] ) if @app_info
  end
end