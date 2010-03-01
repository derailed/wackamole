require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require 'capybara'
require 'capybara/dsl'
require File.join(File.dirname(__FILE__), %w[.. ui_utils mission_util])

include Capybara
include MissionUtil

describe 'Mission' do
  before( :all ) do
    Capybara.default_driver = :selenium
    @url = "http://localhost:4567/"
  end
  
  before :each do
    visit( @url )
    login( @url, 'admin', 'admin', @url + 'mission' )
    rows = all( :css, "table#mission tr.app_info" )
    show_logs( rows[0], 'app1', 'test', 0 )
    current_url.should == @url + "logs/1"    
  end
  
  after :each do
    log_out
  end
  
  it "should filter log's type correctly" do    
    expected = { 'Perf' => 4, 'Fault' => 2 }
    expected.each_pair do |k,v|    
      within( "//form[@id='filter_form']" ) do
        locate( :css, "select#time_frame").select( 'today' )
        locate( :css, "select#hourly_frame").select( 'all' )            
        locate( :css, "select#type").select( k )
        click_button( 'Filter' )
      end
      sleep( 0.2 )
      find( :css, 'div.page_entries' ).text.should =~ /#{v}/          
    end
  end
  
  it "should filter log's time range correctly" do
    expected = { 'today' => 12, '2 days' => 15 }
    expected.each_pair do |k,v|    
      within( "//form[@id='filter_form']" ) do
        locate( :css, "select#hourly_frame").select( 'all' )    
        locate( :css, "select#type").select( 'All' )        
        locate( :css, "select#time_frame").select( k )
        click_button( 'Filter' )
      end
      sleep( 0.2 )
      find( :css, 'div.page_entries' ).text.should =~ /#{v}/          
    end
  end

  it "should filter log's hour correctly" do
    expected = { '17' => 5, '18' => 1 }
    expected.each_pair do |k,v|    
      within( "//form[@id='filter_form']" ) do
        locate( :css, "select#type").select( 'All' )
        locate( :css, "select#time_frame").select( 'today' )        
        locate( :css, "select#hourly_frame").select( k )
        click_button( 'Filter' )
      end
      sleep( 0.2 )      
      find( :css, 'div.page_entries' ).text.should =~ /#{v}/          
    end
  end
end