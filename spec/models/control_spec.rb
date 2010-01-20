require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Wackamole::Control do
  describe 'errors' do
    before( :all ) do
      Wackamole::Control.reset!
    end
    
    it "should raise an error if not correctly initialized" do
      lambda{ Wackamole::Control.connection }.should raise_error( /You must call init_config/ )
    end
  
    it "should raise an error if invalid config file" do
      config_file = File.join(File.dirname(__FILE__), %w[.. config blee.yml])    
      lambda {
        Wackamole::Control.init_config( config_file, 'test' )
      }.should raise_error( /Hoy! An error occur loading the config file `#{config_file} -- No such file or directory/ )
    end
  
    it "should raise an error if a bogus env is requested" do
      config_file = File.join(File.dirname(__FILE__), %w[.. config test.yml])    
      lambda {
        Wackamole::Control.init_config( config_file, 'production' )
      }.should raise_error( /Hoy! An error occur loading the config file `#{config_file} -- Invalid environment `production/ )
    end
  
    it "should raise an error if invalid config file content" do
      config_file = File.join(File.dirname(__FILE__), %w[.. config bogus_test.yml])
      lambda {
        Wackamole::Control.init_config( config_file, 'test' )
      }.should raise_error( /Hoy! An error occur loading the config file `#{config_file} -- Unable to find host in -/ )
    end
  end
  
  describe 'connection' do
    before :all do
      Wackamole::Control.reset!        
      Wackamole::Control.init_config( File.join(File.dirname(__FILE__), %w[.. config test.yml]), 'test' )
      Wackamole::Control.connection.should_not be_nil
    end
    
    describe "#collection" do
      it "should find a collection correctly" do
        cltn = Wackamole::Control.collection( 'features', "mole_fred_development_mdb" )
        cltn.count.should == 10
        feature = cltn.find_one()
        feature['app'].should == "fred"
        feature['env'].should == "development"
        feature['did'].should == Fixtures.test_time_id.to_s
        feature['ctx'].should match( /feature_\d{1}/ )
      end
    end
    
    describe "mole databases" do
      it "should correctly identify mole dbs" do
        # gen_bogus_dbs
        mole_dbs = Wackamole::Control.mole_databases        
        mole_dbs.should have(3).items
      end
      
      it "should extra app/env correctly" do
        Wackamole::Control.extract_app_info( "mole_fred_development_mdb" ).should == ['fred', 'development']
      end
      
      it "should fail to extract app info for an invalid mole db" do
        lambda {
          Wackamole::Control.extract_app_info( "mole_fred_mdb" )
        }.should raise_error( /Invalid mole db specification mole_fred_mdb/ )
      end
      
      it "should connect to a mole databases correctly" do
        %w[test production development].each do |env|
          Wackamole::Control.db( "mole_fred_#{env}_mdb" )
          feature = Wackamole::Control.collection( 'features' ).find_one()
          feature['app'].should == "fred"
          feature['env'].should == env
        end
      end    
      
      it "should switch mole dbs correctly" do
        %w[test production development].each do |env|
          Wackamole::Control.switch_mole_db!( "fred", env )
          feature = Wackamole::Control.collection( 'features' ).find_one()
          feature['app'].should == "fred"
          feature['env'].should == env
        end        
      end  
      
      it "should fail to switch if there is no mole db" do
        lambda{ Wackamole::Control.switch_mole_db!( "blee", "test" ) }.should raise_error( /Invalid mole database mole_blee_test_mdb/ )
      end
      
      it "should fail to switch for an invalid mole db" do
        lambda{ Wackamole::Control.switch_mole_db!( "zorg", "missing" ) }.should raise_error( /Invalid mole database mole_zorg_missing_mdb/ )
      end
    end
  end
end