require 'sinatra'
require 'forwardable'
require 'mongo'
require 'will_paginate'
require 'mongo_rack'
require 'rackamole'

require File.expand_path( File.join( File.dirname(__FILE__), 'wackamole.rb' ) )

set :public, File.join( File.dirname(__FILE__), %w[.. public] )
set :views , File.join( File.dirname(__FILE__), %w[.. views] )

def default_config
  File.join( ENV['HOME'], %w[.wackamole zones.yml] )    
end

# -----------------------------------------------------------------------------
# Configurations

configure :production do
  set :logging, false
end

configure :development do
  set :logging, true
end

configure do
  set :sessions, false
    
  Wackamole.load_all_libs_relative_to(__FILE__, 'helpers' )
  Wackamole.load_all_libs_relative_to(__FILE__, 'controllers' )
  
  #Pick up command line args if any?  
  if defined? @@options and @@options
    if @@options[:protocol] == 'mongo'
      use Rack::Session::Mongo, 
        :server    => "%s:%d/%s/%s" % [@@options[:host], @@options[:port], @@options[:db_name], @@options[:cltn_name]],
        :log_level => :debug
    else
      use Rack::Session::Memcache, 
        :memcache_server => "%s:%d" % [@@options[:host], @@options[:port]],
        :namespace       => @@options[:namespace]
    end
  else
    # Default is local memcache on default port.
    use Rack::Session::Memcache, 
      :memcache_server => "%s:%d" % ['localhost', 11211],
      :namespace       => 'wackamole'
    
    # Default is a mongo session store
    # use Rack::Session::Mongo, 
    #   :server => "%s:%d/%s/%s" % ['localhost', '27017', 'wackamole_ses', 'sessions'],
    #   :log_level => :error
  end  
  Wackamole::Control.init_config( default_config )
end

# -----------------------------------------------------------------------------
# Before filters
before do  
  unless request.path =~ /\.[css gif png js]/
    if console_auth?
      unless request.path == '/' or request.path == '/session/create' or request.path == '/session/delete'
        unless authenticated?
          redirect '/'
        end
      end
    end
        
    @filter = session[:filter]
    unless @filter
      @filter = Wackamole::SearchFilter.new
      session[:filter] = @filter
    end
    @updated_on   = Time.now
    @refresh_rate = 30
    @app_info     = session[:app_info]
    Wackamole::Control.ensure_db( session[:context] ) if session[:context]

    # begin
    #   Wackamole::Control.switch_mole_db!( @app_info[:app].downcase, @app_info[:stage] ) if @app_info
    # rescue => boom
    #   $stderr.puts boom      
    #   @app_info          = nil
    #   session[:app_info] = nil
    # end
  end
end
