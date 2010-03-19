require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])
require 'chronic'

describe Wackamole::Mission do  
  before :all do
    Wackamole::Control.init_config( File.join(File.dirname(__FILE__), %w[.. .. config test.yml]) )
    Wackamole::Control.current_db( "test", "app1", "test", true )
    now = Time.now-24*60*60
    @test_time = Chronic.parse( "%d/%2d/%2d 00:00:01" % [now.year,now.month,now.day] )    
    # @test_time = Chronic.parse( "2010/01/01 01:00:00" ).utc 
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
    
  it "should pick up an app pulse correctly" do
    zones = Wackamole::Mission.pulse( @test_time )
    zones.should have(1).items
    apps = zones['test']
    apps.should have(2).items
    expected = {'to_date' => [7,5,3], 'today' => [3,2,1] }
    %w(to_date today).each do |p|
      %w(app1 app2).each do |app|
        [0, 1, 2].each do |type|
          zones['test'][app]['test'][p.to_sym][type].should == expected[p][type]
        end
      end
    end
    # %w(app1 app2).each do |app|
    #   expected = [3,2,1]
    #   [0, 1, 2].each do |type|
    #     pulse[:last_tick][app]["test"][type].should == expected[type]
    #   end
    # end    
  end  
end
