require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])
require 'chronic'

describe Wackamole::User do
  before( :all ) do
    Wackamole::Control.init_config( File.join(File.dirname(__FILE__), %w[.. .. config test.yml]), 'test' )
    Wackamole::Control.connection.should_not be_nil
    Wackamole::Control.db( "mole_app1_test_mdb" )
  end
  
  it "should paginate a user collection correctly" do
    cltn = Wackamole::User.paginate_tops( {}, 1, 2 )
    cltn.total_entries.should == 2
    cltn.size.should == 2
    cltn.total_pages.should == 1
  end
  
  describe "indexes" do
    before :all do
      @cltn = Wackamole::User.users_cltn
      @cltn.should_not be_nil
      @cltn.drop_indexes
    end
    
    it "should set up indexes correctly" do
      indexes = @cltn.index_information
      indexes.should have(1).item  
      count = Wackamole::User.ensure_indexes!  
      count.should == 1
      indexes = @cltn.index_information
      indexes.should have(2).items
    end
    
    it "should do nothing if indexes are already present" do
      indexes = @cltn.index_information
      indexes.should have(2).items   
      count = Wackamole::User.ensure_indexes!
      count.should == 1
      indexes = @cltn.index_information
      indexes.should have(2).items      
    end
  end
  
end
