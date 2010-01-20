require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe DateTime do    
  it "should convert a date to date_id correctly" do
    DateTime.parse( "2010-01-01" ).to_date_id.should == 20100101
  end
    
end