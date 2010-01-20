require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Time do    
  it "should convert a time to date_id correctly" do
    Chronic.parse( "2010-01-01 09:30:59" ).to_date_id.should == 20100101
  end

  it "should convert a time to time_id correctly" do
    Chronic.parse( "2010-01-01 10:30:59" ).to_time_id.should == "103059"
  end
    
end