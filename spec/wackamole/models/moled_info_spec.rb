require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])
require 'chronic'

describe Wackamole::MoledInfo do
  before( :all ) do
    Wackamole::Control.init_config( File.join(File.dirname(__FILE__), %w[.. .. config test.yml]) )
    Wackamole::Control.current_db( "test", "app1", "test", true )
    now = Time.now-24*60*60
    @test_time = Chronic.parse( "%d/%2d/%2d 18:00:01" % [now.year,now.month,now.day] )
  end
  
  it "should gather dashboard info correctly" do
    info = Wackamole::MoledInfo.collect_dashboard_info( @test_time )
        
    info[:total_users].should    == 5
    info[:user_load].should      == 2
    info[:total_features].should == 6
    info[:feature_load].should   == 1
    info[:fault_load].should     == 1
    info[:perf_load].should      == 2
    
    info[:user_series].should    == series_for( [[18,2]] )
    info[:feature_series].should == series_for( [[18,2]] )
    info[:fault_series].should   == series_for( [[18,1]] )
    info[:perf_series].should    == series_for( [[18,2]] )
  end  
  
  def series_for( slots )
    series = 24.times.collect { |i| 0 }
    slots.each do |pair|
      series[pair.first] = pair.last
    end
    series
  end
end
