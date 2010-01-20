require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require 'chronic'

describe Wackamole::Mission do  
  before :all do
    Wackamole::Control.reset!
    Wackamole::Control.init_config( File.join(File.dirname(__FILE__), %w[.. config test.yml]), 'test' )
    Wackamole::Control.connection.should_not be_nil    
    @test_time = Chronic.parse( "2010/01/01 01:00:00" ).utc 
  end
  
  describe '#to_type_name' do
    it "should convert a type to a name correctly" do
      %w[feature perf fault].each do |type|
        name = Wackamole::Mission.to_type_name( Rackamole.send( type ) )
        name.should == "#{type}s"
      end
    end
    
    it "should raise an error if a type is invalid" do
      lambda {
        Wackamole::Mission.to_type_name( "fred" )
      }.should raise_error( /Invalid mole log type `fred/ )
    end
  end
    
  describe "#rollups" do
    before( :each ) do
      @con = Wackamole::Control.connection
      db = @con.db( 'wackamole_mdb' )
      db['rollups'].remove( {} )
    end
    
    after( :each ) do
      @con.drop_database( "mole_blee_test_mdb" )
      @con.drop_database( "mole_blee_development_mdb" )      
    end

    it "should rollup statuses for a time correctly" do
      rollups = Wackamole::Mission.rollups( @test_time, false )
      rollups.should have(1).item
      rollup = rollups.first
      rollup['envs'].should have(3).items
      envs     = %w[development production test]
      rollup['app'].should == 'fred'
      rollup['envs'].each_pair do |env, info|
        envs.include?( env ).should == true
        envs = envs - [env]
        info.keys.sort.should == %w[faults features perfs]
        info.values.should   == [2, 2, 2]
      end      
    end
    
    it "should rollup statuses for the day correctly" do
      rollups = Wackamole::Mission.rollups( @test_time, true )
      rollups.should have(1).item
      rollup = rollups.first
      rollup['envs'].should have(3).items
      envs     = %w[development production test]
      rollup['app'].should == 'fred'
      rollup['envs'].each_pair do |env, info|
        envs.include?( env ).should == true
        envs = envs - [env]
        info.keys.sort.should == %w[faults features perfs]
        info.values.should   == [7, 7, 7]
      end      
    end
    
    it "should update a rollup correctly" do
      Wackamole::Mission.rollups( @test_time, false )
      rollups = Wackamole::Mission.rollups( @test_time, false )      
      rollups.should have(1).item
      rollup = rollups.first
      rollup['envs'].should have(3).items
      envs     = %w[development production test]
      rollup['app'].should == 'fred'
      rollup['envs'].each_pair do |env, info|
        envs.include?( env ).should == true
        envs = envs - [env]
        info.keys.sort.should == %w[faults features perfs]
        info.values.should   == [4, 4, 4]
      end      
    end
  
    describe "#reset!" do
      it "should clear out a mole correctly" do
        Fixtures.create_valid_mole_db( @con, 'blee', "test" )
        rollups = Wackamole::Mission.rollups( @test_time, false )        
        rollup  = Wackamole::Mission.rollups_cltn.find_one( { :app => 'blee' } )
        rollup.should_not be_nil
        %w[features perfs faults].each do |type|
          rollup['envs']['test'][type].should == 2
        end
        Wackamole::Mission.reset!( 'blee', 'test', 'faults' )
        rollup  = Wackamole::Mission.rollups_cltn.find_one( { :app => 'blee' } )
        rollup['envs']['test']['faults'].should == 0
        %w[features perfs].each do |type|
          rollup['envs']['test'][type].should == 2
        end
      end
    end
    
    describe '#clean!' do
      before( :each ) do
        @con.drop_database( "mole_blee_test_mdb" )
        @con.drop_database( "mole_blee_development_mdb" )
      end
    
      it "should update the rollups if an env is no longer in the db" do
        Fixtures.create_valid_mole_db( @con, 'blee', "test" )
        Fixtures.create_valid_mole_db( @con, 'blee', "development" )      
        rollups = Wackamole::Mission.rollups( @test_time, false )
        rollups.should have(2).items
        @con.drop_database( "mole_blee_test_mdb" )
        rollups = Wackamole::Mission.rollups( @test_time, false )
        rollups.should have(2).items
        rollup = Wackamole::Mission.rollups_cltn.find_one( { :app => 'blee' } )
        rollup.should_not be_nil
        rollup['envs'].should have(1).item
      end

      it "should remove a rollup if an app is no longer in the db" do
        Fixtures.create_valid_mole_db( @con, 'blee', "test" )
        rollups = Wackamole::Mission.rollups( @test_time, false )
        rollups.should have(2).items
        @con.drop_database( "mole_blee_test_mdb" )
        rollups = Wackamole::Mission.rollups( @test_time, false )
        rollups.should have(1).items
      end    
    end
  end
    
  describe "#comp_applications" do
    it "should gather report for a given day correctly" do
      report = Wackamole::Mission.comb_applications( @test_time, true )
      report.should have(1).item
      report['fred'].should_not be_nil
      report['fred']['envs'].should have(3).items
      
      envs     = %w[development production test]
      expected = { 0 => 7, 1 => 7, 2 => 7}
      report['fred']['envs'].each_pair do |env, info|
        envs.include?( env ).should == true
        envs = envs - [env]
        info.should == expected
      end
    end
    
    it "should gather report for a given time correctly" do
      report = Wackamole::Mission.comb_applications( @test_time, false )
      report.should have(1).item
      report['fred'].should_not be_nil
      report['fred']['envs'].should have(3).items
      
      envs     = %w[development production test]      
      expected = { 0 => 2, 1 => 2, 2 => 2}      
      report['fred']['envs'].each_pair do |env, info|
        envs.include?( env ).should == true
        envs = envs - [env]
        info.should == expected
      end
    end
  end
  
  describe "#analyse_logs" do
    before :all do  
      @db = Wackamole::Control.switch_mole_db!( "fred", "test" )
    end

    it "should find no analyses after 2am" do
      test_time = Chronic.parse( "2010/01/01 02:00:00" ).utc       
      analysis = Wackamole::Mission.analyse_logs( @db, test_time, false )
      [0, 1, 2].each{ |type| analysis[type].should == 0 }
    end
        
    it "should analyse a log for a given time correctly" do
      test_time = Chronic.parse( "2010/01/01 01:00:00" ).utc       
      analysis = Wackamole::Mission.analyse_logs( @db, test_time, false )
      [0, 1, 2].each{ |type| analysis[type].should == 2 }
    end
    
    it "should analyse logs for a day correctly" do
      analysis = Wackamole::Mission.analyse_logs( @db, @test_time, true )
      [0, 1, 2].each{ |type| analysis[type].should == 7 }
    end      
  end
  
  describe "#amend_report" do
    it "should amend an empty report correctly" do
      report = {}
      %w[development test production].each do |env|
        %w[feature fault perf].each do |type|
          type_num = Rackamole.send( type )
          log    = { 'typ' => type_num }
          Wackamole::Mission.amend_report( report, "fred", env, log )
          report['fred']['envs'][env][type_num].should == 1
        end
      end
    end
    
    it "should amend an existing report with no recorded info correctly" do
      report = { "fred" => { 'envs' => {} } }
      %w[development test production].each do |env|
        %w[feature fault perf].each do |type|
          type_num = Rackamole.send( type )
          log    = { 'typ' => type_num }
          Wackamole::Mission.amend_report( report, "fred", env, log )
          report['fred']['envs'][env][type_num].should == 1
        end
      end
    end    
    
    it "should amend an existing report correctly" do
      report = { "fred" => {'envs' => { 'test' => { 0 => 1, 1 => 1, 2 => 1 } } }}
      %w[development test production].each do |env|
        %w[feature fault perf].each do |type|
          type_num = Rackamole.send( type )
          log    = { 'typ' => type_num }
          Wackamole::Mission.amend_report( report, "fred", env, log )   
          report['fred']['envs'][env][type_num].should == (env == "test" ? 2 : 1)
        end
      end
    end
  end  
end
