require File.expand_path( File.join(File.dirname(__FILE__), %w[.. .. spec_helper] ) )
require 'chronic'

describe Wackamole::Log do
  before( :all ) do
    Wackamole::Control.init_config( File.join(File.dirname(__FILE__), %w[.. .. config test.yml]) )
    Wackamole::Control.current_db( "test", "app1", "test", true )
  end
    
  it "should paginate logs correctly" do
    cltn = Wackamole::Log.paginate( {}, 1, 5 )
    cltn.total_entries.should == 15
    cltn.size.should          == 5
    cltn.total_pages.should   == 3
  end
  
  describe "indexes" do
    before :all do
      @cltn = Wackamole::Log.logs_cltn
      @cltn.should_not be_nil      
      @cltn.drop_indexes
    end
    
    it "should set up indexes correctly" do
      indexes = @cltn.index_information
      indexes.should have(1).item
      count = Wackamole::Log.ensure_indexes!
      count.should == 2
      indexes = @cltn.index_information   
      indexes.should have(5).items
    end
    
    it "should do nothing if indexes are already present" do
      indexes = @cltn.index_information
      indexes.should have(5).items   
      count = Wackamole::Log.ensure_indexes!
      count.should == 0
      indexes = @cltn.index_information   
      indexes.should have(5).items      
    end
  end
end
