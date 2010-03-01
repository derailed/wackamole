require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])
require 'chronic'

describe Wackamole::Mission do  
  before :all do
    Wackamole::Control.reset!
    Wackamole::Control.init_config( File.join(File.dirname(__FILE__), %w[.. .. config test.yml]), 'test' )
    Wackamole::Control.connection.should_not be_nil    
    now = Time.now
    @test_time = Chronic.parse( "%d/%2d/%2d 17:00:00" % [now.year,now.month,now.day] )    
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
    pulse = Wackamole::Mission.pulse( @test_time )
    pulse.should have(3).items
    pulse[:to_date].should_not be_nil
    pulse[:today].should_not be_nil    
    pulse[:last_tick].should_not be_nil
    expected = {'to_date' => [7,5,3], 'today' => [6,4,2] }
    %w(to_date today).each do |p|
      %w(app1 app2).each do |app|
        [0, 1, 2].each do |type|
          pulse[p.to_sym][app]["test"][type].should == expected[p][type]
        end
      end
    end
    %w(app1 app2).each do |app|
      expected = [3,2,1]
      [0, 1, 2].each do |type|
        pulse[:last_tick][app]["test"][type].should == expected[type]
      end
    end    
  end  
end
