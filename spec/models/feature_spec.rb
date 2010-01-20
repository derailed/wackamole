require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require 'chronic'

describe Wackamole::Feature do
  before( :all ) do
    Wackamole::Control.init_config( File.join(File.dirname(__FILE__), %w[.. config test.yml]), 'test' )
    Wackamole::Control.connection.should_not be_nil
    Wackamole::Control.db( "mole_fred_test_mdb" )
  end
  
  it "retrieve an app info correctly" do
    app_info = Wackamole::Feature.get_app_info
    app_info.should_not be_nil
    app_info.should have(2).items
    app_info[:app_name].should == "fred"
    app_info[:stage].should  == "test"
  end
  
  it "should paginate features correctly" do
    cltn = Wackamole::Feature.paginate_tops( {}, 1, 5 )
    cltn.total_entries.should == 7
    cltn.size.should == 5
    cltn.total_pages.should == 2  
  end
  
  describe "indexes" do
    before :all do
      @cltn = Wackamole::Feature.features_cltn
      @cltn.should_not be_nil
      @cltn.drop_indexes
    end
    
    it "should set up indexes correctly" do
      indexes = @cltn.index_information
      indexes.should have(1).item      
      count = Wackamole::Feature.ensure_indexes!  
      count.should == 3
      indexes = @cltn.index_information
      indexes.should have(3).items
    end
    
    it "should do nothing if indexes are already present" do
      indexes = @cltn.index_information
      indexes.should have(3).items   
      count = Wackamole::Feature.ensure_indexes!
      count.should == 1
      indexes = @cltn.index_information
      indexes.should have(3).items      
    end
  end
  
end
