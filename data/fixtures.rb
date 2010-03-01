require "rubygems"
require "mongo"
require 'rackamole'
require 'wackamole'

class Fixtures
  attr_reader :con
  
  def mole_collections() %w(users features logs); end
    
  def initialize( host='localhost', port=27099 )
    puts "Loading fixture data"
    @con = Mongo::Connection.new( host, port )
  end
  
  def clear
    con.database_names.select do |db_name|
      if db_name =~ /^mole_/
        puts "Dropping db #{db_name}"
        @con.drop_database( db_name )
      end
    end
  end
  
  def populate
    clear
    apps = [
      %w(app1 test),
      %w(app2 test)
    ]
    apps.each { |config| create_mole_db( config.first, config.last ) }
  end

  def create_mole_db( app_name, env )
    db_name = mole_db_name( app_name, env )
    provision( db_name )
  end

  def provision( db_name )
    db = con.db( db_name )
    clear_collections(db) if db
    
    populate_features( db )
    populate_users( db )
    populate_logs( db )
  end
  
  def populate_features( db )
    app_name, stage = Wackamole::Control.extract_app_info( db.name )    
    %w(/ /normal /params/10 /error /slow /post ).each do |ctx|
      row = { 
        :app => app_name,
        :env => stage,
        :did => Time.now.utc.to_date_id.to_s,
        :ctx => ctx
      }
      db['features'].insert( row )
    end    
  end
  
  def populate_users( db )
    %w(fernand bobo bubba eddie freddie).each do |user|
      row = { :una => user, :did => Time.now.to_date_id }
      db['users'].insert( row )
    end
  end
  
  def populate_logs( db )
    logs_cltn = db['logs']
    user_config = {
      'fernand' => {
        :days       => 2,
        :activities => [2, 1, 0]
       },
      'bobo' => {
        :days       => 3,
        :activities => [1, 1, 1]
       }        
    }
    user_config.each_pair do |user_name, activity|
      user = db['users'].find_one( { :una => user_name } )
      (0...activity[:days]).each do |day|
        date = Time.now - day*(24*60*60)
        count = 0
        [Rackamole.feature, Rackamole.perf, Rackamole.fault].each do |type|
          create_logs( db, logs_cltn, activity[:activities][count], type, date.utc, user )
          count += 1
        end
      end 
    end
  end
  
  def create_logs( db, logs_cltn, count, type, time, user )
    date_id = time.to_date_id
    features = db['features'].find( {} ).to_a
    (0...count).each do |i|
      time_id = "%02d0100" % (i%23)
      create_log( logs_cltn, type, date_id, time_id, user, features[i%features.size] )
    end
  end
  
  def create_log( logs_cltn, type, date_id, time_id, user, feature )
    row = {
      :url => "http://localhost:3000#{feature['ctx']}",
      :typ => type,
      :fid => feature['_id'],
      :hos => 'localhost',
      :met => 'GET',
      :sts => 200,
      :did => date_id.to_s,
      :tid => time_id.to_s,
      :rti => (type == Rackamole.perf ? 10 : 1),
      :bro => { :version => '1.0', :name => 'Firefox' },
      :sof => "thin 1.2.5 codename This Is Not A Web Server",
      :hdr => { 'Content-Type' => 'text/html', 'Content-Length' => 100 },
      :par => { :blee => 10, :duh => "bumblebeetuna" },
      :uid => user['_id'],
      :mac => { :version => 10.6, :platform => 'Macintosh', :os => 'Intel Mac OS X' },
      :ses => { :user_name => user['una'] }
    }
    logs_cltn.insert( row )
  end
      
  def mole_db_name( app_name, env )
    "mole_#{app_name}_#{env}_mdb"
  end
    
  def clear_collections( db )
    mole_collections.each { |cltn| db.drop_collection( cltn ) }
  end
end

Fixtures.new.populate