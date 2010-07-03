require File.expand_path( File.join(File.dirname(__FILE__), %w[.. .. spec_helper] ) )

describe Wackamole::SearchFilter do    
  before( :each ) do
    @filter    = Wackamole::SearchFilter.new
    now        = Time.now
    @test_time = Time.local( now.year, now.month, now.day, 17, 0, 0 )
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
    
  it "should retrieve the correct feature context" do
    @filter.context_for( {'ctx' => "/blee/fred" } ).should == "/blee/fred"
    @filter.context_for( {'ctl' => "blee", 'act' => "fred" } ).should == "blee#fred"
  end
  
  it "should retrieve the correct start date" do
    @filter.from_date_id.should_not be_nil
  end
  
  it "should map id to type correctly" do
    types = %w( Feature Perf Fault )
    [0,1,2].each do |t|
      @filter.send( :to_filter_type, t ).should == types[t]
    end
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
      conds.key?( '$where' ).should == true
      conds['$where'].should == "((this.did == '#{@test_time.to_date_id}' && this.tid >= '060001') || ( this.did == '#{(@test_time+24*60*60).to_date_id}' && this.tid <= '055959') )"
    end
    
    it "should include browser if specified correctly" do
      @filter.browser_type = 'Safari'
      conds = @filter.to_conds
      time = Chronic.parse( "now" ).utc
      conds.should have(2).items
      conds['bro.name'].should == "Safari"
    end
    
    it "should include mole type is specfied" do
      @filter.browser_type = 'Safari'      
      @filter.type         = Wackamole::SearchFilter.mole_types[1]
      conds = @filter.to_conds
      time = Chronic.parse( "now" ).utc  
      conds.should have(3).items
      conds['bro.name'].should == "Safari"
      conds[:typ].should == Rackamole.feature
    end

    it "should include feature is specfied" do
      @filter.feature_id = "4b25b0049983a8a193000010"    
      conds = @filter.to_conds
      time = Chronic.parse( "now" ).utc
      conds.should have(2).items
      conds[:fid].should == BSON::ObjectID.from_string( "4b25b0049983a8a193000010" )
    end
    
    describe "search terms" do
      before( :all ) do
        Wackamole::Control.init_config( File.join(File.dirname(__FILE__), %w[.. .. config test.yml]) )
        Wackamole::Control.current_db( "test", "app1", "test", true )
      end
      
      it "should retrieve features correctly" do
        features = @filter.features
        features.should have(7).items
        count = 0
        expected = %w(All / /error /normal /params/10 /post /slow)
        features.each do |f|
          f.should have(2).items
          f.first.should == expected[count]
          count += 1
        end
      end
      
      it "should include user if specified" do
        @filter.search_terms = "user:fernand"    
        conds = @filter.to_conds
        conds.should have(2).items
        conds[:uid].should_not be_nil
        conds[:uid].key?( "$in" ).should == true
        conds[:uid]["$in"].should have(1).item
        conds[:uid]["$in"].first.to_s.size.should == 24
      end
      
      it "should include an adoc regexp if specified" do
        @filter.search_terms = "host:blee"    
        conds = @filter.to_conds        
        conds.should have(2).items
        conds[:hos].should_not be_nil
        conds[:hos].should == /blee/
      end

      it "should include an adoc regexp if specified" do
        @filter.search_terms = "browser:name:duh"    
        conds = @filter.to_conds
        conds.should have(2).items
        conds['bro.name'].should_not be_nil
        conds['bro.name'].should == /duh/
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