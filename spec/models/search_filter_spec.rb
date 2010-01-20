require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Wackamole::SearchFilter do    
  before( :each ) do
    @filter = Wackamole::SearchFilter.new
  end
  
  it "should initialize with the correct defaults" do
     @filter = Wackamole::SearchFilter.new
     check_filter( @filter, "today", "All", "", -1)
  end
  
  it "should reset a filter correctly" do
    @filter = Wackamole::SearchFilter.new
    @filter.time_frame   = "1 year"
    @filter.browser_type = "Safari"
    @filter.search_terms = "blee"
    @filter.feature_id   = 10
    check_filter( @filter, "1 year", "Safari", "blee", 10 )    
    @filter.reset!
    check_filter( @filter, "today", "All", "", -1)
  end
  
  describe "series" do
    it "should generate the correct time_ids" do
      @filter.time_frame = "7 days"
      @filter.time_ids.should have(8).items
      @filter.time_ids.each { |did| did.size.should == 8 }
    end
    
    it "should generate the correct time series" do
      @filter.time_frame = "10 days"
      @filter.time_series.should have(11).items
      @filter.time_series.each { |date| date.should match( /\d{4}\-\d{2}\-\d{2}/) }
    end
  end
  
  it "should populate correctly from request params" do
    @filter.from_options( {:time_frame => '1 year', :browser_type => 'Safari', :search_terms => "blee", :feature_id => 100 } )
    check_filter( @filter, "1 year", "Safari", "blee", 100 )
  end
  
  describe "#to_conds"
    before :all do
      @now = Time.now   
    end
    
    it "should spews default filter query conds correctly" do
      conds = @filter.to_conds
      conds.should have(1).item
      conds.key?( :did ).should == true
      conds[:did].should == { "$gte" => @now.to_date_id.to_s }
    end
    
    it "should include browser if specified correctly" do
      @filter.browser_type = 'Safari'
      conds = @filter.to_conds
      time = Chronic.parse( "now" ).utc
      conds.should have(2).items
      conds.key?( :did ).should == true
      conds[:did].should == { "$gte" => @now.to_date_id.to_s }
      conds[:bro].should == "Safari"
    end
    
    it "should include mole type is specfied" do
      @filter.browser_type = 'Safari'      
      @filter.type         = Wackamole::SearchFilter.mole_types[1]
      conds = @filter.to_conds
      time = Chronic.parse( "now" ).utc  
      conds.should have(3).items
      conds.key?( :did ).should == true
      conds[:did].should == { "$gte" => @now.to_date_id.to_s }
      conds[:bro].should == "Safari"
      conds[:typ].should == Rackamole.feature
    end

    it "should include feature is specfied" do
      @filter.feature_id = "4b25b0049983a8a193000010"    
      conds = @filter.to_conds
      time = Chronic.parse( "now" ).utc
      conds.should have(2).items
      conds.key?( :did ).should == true
      conds[:did].should == { "$gte" => @now.to_date_id.to_s }
      conds[:fid].should == Mongo::ObjectID.from_string( "4b25b0049983a8a193000010" )
    end
    
    describe "search terms" do
      before( :all ) do
        Wackamole::Control.init_config( File.join(File.dirname(__FILE__), %w[.. config test.yml]), 'test' )
        Wackamole::Control.connection.should_not be_nil
        Wackamole::Control.db( "mole_fred_test_mdb" )
      end
      
      it "should include user if specified" do
        @filter.search_terms = "user:blee_0@fred.test"    
        conds = @filter.to_conds
        conds.should have(2).items
        conds[:uid].should_not be_nil
        conds[:uid].key?( "$in" ).should == true
        conds[:uid]["$in"].should have(1).item
        conds[:uid]["$in"].first.to_s.size.should == 24
      end
      
      it "should include an adoc regexp if specified" do
        @filter.search_terms = "key:blee"    
        conds = @filter.to_conds
        conds.should have(2).items
        conds['key'].should_not be_nil
        conds['key'].should == /blee/
      end

      it "should include an adoc regexp if specified" do
        @filter.search_terms = "key:blee:duh"    
        conds = @filter.to_conds
        conds.should have(2).items
        conds['key.blee'].should_not be_nil
        conds['key.blee'].should == /duh/
      end
      
      it "should raise an exception is search exp cannot be parsed" do
        lambda {
          @filter.search_terms = "key:blee:duh:booba"    
          conds = @filter.to_conds          
        }.should raise_error /Unable to evaluate search terms/
      end
    end
    
    describe "#map_mole_type" do
      it "should map mole types correctly" do
        %w[Feature Perf Fault].each { |type| @filter.send( :map_mole_type, type ).should == Rackamole.send( type.downcase ) }
      end
      
      it "should crap out for invalid mole types" do
        lambda {
          @filter.send( :map_mole_type, "bozo" )
        }.should raise_error( /Invalid mole type `bozo/ )
      end
    end
    
    it "should reset a time stamp correctly" do
      @filter.send( :now ).strftime( "%H:%M:%S" ).should match( /00\:00\:00/ )
    end
end


def check_filter( filter, time_frame, browser, terms, feature_id )
  filter.time_frame.should   == time_frame
  filter.browser_type.should == browser
  filter.search_terms.should == terms
  filter.feature_id.should   == feature_id
end