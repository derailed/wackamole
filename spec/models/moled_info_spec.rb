require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require 'chronic'

describe Wackamole::MoledInfo do
  before( :all ) do
    Wackamole::Control.init_config( File.join(File.dirname(__FILE__), %w[.. config test.yml]), 'test' )
    Wackamole::Control.connection.should_not be_nil
    Wackamole::Control.db( "mole_fred_test_mdb" )
    @test_time = Chronic.parse( "2010/01/01 01:00:00" )
  end
  
  it "should gather dashboard info correctly" do
    info = Wackamole::MoledInfo.collect_dashboard_info( @test_time )
    
    info[:total_users].should    == 10
    info[:user_load].should      == 2
    info[:total_features].should == 10
    info[:feature_load].should   == 2
    info[:fault_load].should     == 2
    info[:perf_load].should      == 2
    
    series = 24.times.collect { |i| 0 }
    series[0] = 5
    series[1] = 2
    info[:user_series].should    == series
    info[:feature_series].should == series
    info[:fault_series].should   == series
    info[:perf_series].should    == series
  end  
end
