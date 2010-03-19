require 'rackamole'

class Fixtures

  def self.test_time_id() @test_time ||= 20100101; end
  
  def self.load_data
    puts "Loading fixture data..."    
    Wackamole::Control.init_config( File.join(File.dirname(__FILE__), %w[.. config test.yml]), 'test' )
    load_test_dbs
    load_bogus_dbs
  end

  def self.load_test_dbs
    con = Wackamole::Control.connection( 'test' )
    %w[development test production].each{ |env| create_valid_mole_db( con, "fred", env) }
  end
  
  def self.load_bogus_dbs
    con = Wackamole::Control.connection( 'test' )
    %w[mole_blee_mdb zorg_blee_dev_mdb].each do |db_name|
      create_db( con, db_name )
    end
    # create mole db with wrong cltns
    # BOZO !! An empty db does not show up?
    db = create_db( con, "mole_zorg_wrong_mdb" )
    %w[features1 logs1 users1].each { |cltn| db.drop_collection( cltn );db.create_collection( cltn ) }  
    # missing cltn
    db = create_db( con, "mole_zorg_missing_mdb" )
    %w[features logs].each { |cltn| db.drop_collection( cltn );db.create_collection( cltn ) }
  end

  def self.create_db( con, db_name )
    # if con.database_names.include?( db_name )
    #   con.drop_database( db_name )
    # end  
    con.db( db_name, :strict => true )  
  end

  def self.create_valid_mole_db( con, app_name, env )
    db_name = "mole_#{app_name}_#{env}_mdb"  
    db = create_db( con, db_name )
    %w[users features logs].each do |cltn_name|
      db.drop_collection( cltn_name )
      cltn = db.create_collection( cltn_name ) # :capped => false, :size => 1_000_000, :limit => 100 )
      case cltn_name
        when 'users'    : populate_users( cltn, app_name, env )      
        when 'features' : populate_features( cltn, app_name, env )
        when 'logs'     : populate_logs( cltn, app_name, env )
      end
    end
  end

  def self.populate_users( cltn, app_name, env )
    10.times do |i|
      cltn.insert( { :una => "blee_#{i}@#{app_name}.#{env}", :did => test_time_id.to_s } )
    end
  end

  def self.populate_features( cltn, app_name, env )
    10.times do |i|
      cltn.insert( { :env => env, :app => app_name, :did => test_time_id.to_s, :ctx => "feature_#{i}" } )
    end
  end

  def self.populate_logs( cltn, app_name, env )
    features = cltn.db['features'].find( {} ).to_a
    users   = cltn.db['users'].find( {} ).to_a
    [Rackamole.feature, Rackamole.perf, Rackamole.fault].each do |type|
      5.times do |i|
        cltn.insert({ 
          :typ => type, 
          :fid => features[i]['_id'], 
          :uid => users[i]['_id'], 
          :did => test_time_id.to_s, 
          :tid => "070000",      
          :ip  => "127.0.0.#{i}" 
        })
      end
      2.times do |i|    
        cltn.insert({ 
          :typ => type, 
          :fid => features[5+i]['_id'], 
          :uid => users[5+i]['_id'], 
          :did => test_time_id.to_s, 
          :tid => "080000",      
          :ip  => "127.0.0.#{i}" 
        })    
      end
    end
  end  
end