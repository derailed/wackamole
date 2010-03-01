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
  end
  
  after :each do
    log_out
  end
  
  it "should gather mission info correctly" do
    rows = all( :css, "table#mission tr.app_info" )
    rows.should have(2).items
        
    check_app( rows[0], 'app1', 'test', [7,5,3], [6,4,2], [0,0,0] )
    check_app( rows[1], 'app2', 'test', [7,5,3], [6,4,2], [0,0,0] )
  end
  
  it "should have the right number of links" do
    rows = all( :css, "table#mission tr.app_info" )
    rows.first.all( :css, "a" ).should have(4).items
    rows.last.all( :css, "a" ).should have(4).items
  end
  
  it "should navigate to an application dasboard correctly" do
    %w(app1).each do |app|
      find_link( app ).click
      current_url.should == "http://localhost:4567/dashboard/#{app}/test"
      # visit( @url )
    end
  end
  
  it "should navigate to logs features correctly" do
    [0,1].each do |i|
      rows = all( :css, "table#mission tr.app_info" )
      cells = rows[i].all( :css, 'td' )
      app = cells[0].text
      env = cells[1].text
      vals = %w(Feature Perf Fault)
      logs = [6,4,2]
      [0,1,2].each do |type|
        rows = all( :css, "table#mission tr.app_info" )        
        show_logs( rows[i], app, env, type )        
        current_url.should == @url + "logs/1"
        find( :css, 'select#type' ).value.should == vals[type]
        find( :css, 'div.page_entries' ).text.should =~ /#{logs[type]}/
        nav_mission
      end
    end
  end
end
