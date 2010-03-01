require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Wackamole do
 before( :all ) do        
    @root = ::File.expand_path( ::File.join(::File.dirname(__FILE__), %w(.. ..) ) )
  end
    
  it "is versioned" do
    Wackamole.version.should =~ /\d+\.\d+\.\d+/
  end
  
  it "generates a correct path relative to root" do
    Wackamole.path( "wackamole.rb" ).should == ::File.join(@root, "wackamole.rb" )
  end
  
  it "generates a correct path relative to lib" do
    Wackamole.libpath(%w[ models control.rb]).should == ::File.join( @root, "lib", "models", "control.rb" )
  end       
  
end