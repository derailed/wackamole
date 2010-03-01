require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require 'capybara'
require 'capybara/dsl'
require File.join(File.dirname(__FILE__), %w[.. ui_utils mission_util])

include Capybara
include MissionUtil

describe 'Sessions' do
  before( :all ) do
    Capybara.default_driver = :selenium
    @url = "http://localhost:4567/"
  end

  it "should login correctly" do
    visit( @url )
    login( @url, 'admin', 'admin', @url + 'mission' )
    log_out
    # within( "//form[@id='login']" ) do
    #   fill_in 'Login'   , :with => 'admin'
    #   fill_in 'Password', :with => 'admin'
    # end
    # click_button 'Log In'
    # current_url.should == @url + "mission"
    # click_link 'log out'
  end
  
  it "should complain for invalid credentials" do
    visit( @url )
    login( @url, 'fernand', 'oh dear', @url )
    # within( "//form[@id='login']" ) do
    #   fill_in 'Login'   , :with => 'fernand'
    #   fill_in 'Password', :with => 'fuck'
    # end
    # click_button 'Log In'
    # current_url.should == @url
    page.should have_css( 'div.flash_error' )
  end
end
