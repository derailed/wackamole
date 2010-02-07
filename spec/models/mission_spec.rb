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
    
  it "should pick up an app pulse correctly" do
    pulse = Wackamole::Mission.pulse( @test_time )
    pulse.should have(3).items
    pulse[:to_date].should_not be_nil
    pulse[:today].should_not be_nil    
    pulse[:last_tick].should_not be_nil
    %w(to_date today).each do |p|
      %w(production development test).each do |e|
        [0, 1, 2].each do |type|
          pulse[p.to_sym]["fred"][e][type].should == 7
        end
      end
    end
    %w(production development test).each do |e|
      [0, 1, 2].each do |type|
        pulse[:last_tick]["fred"][e][type].should == 2
      end
    end    
  end  
end
