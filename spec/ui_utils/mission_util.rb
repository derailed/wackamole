module MissionUtil
  
  def check_app( row, app, env, to_date, today, last_tick )
    cells = row.all( :css, 'td' )
    
    cells[0].text.should == app
    cells[1].text.should == env
    
    to_date_indexes = [4,6,8]
    to_date_indexes.each_index { |i| cells[to_date_indexes[i]].text.should == to_date[i].to_s }

    today_indexes = [11,13,15]
    today_indexes.each_index { |i| cells[today_indexes[i]].text.should == today[i].to_s }    

    last_tick_indexes = [18,20,22]
    last_tick_indexes.each_index { |i| cells[last_tick_indexes[i]].text.should == last_tick[i].to_s }
  end
  
  def show_logs( row, app, env, type )
    row.find( :css, "a##{app}_#{env}_#{type}" ).click
  end
  
  def nav_mission
    page.find_link( 'mission control' ).click
  end
  
  def login( url, username, password, expected_url )
    visit( url )
    within( "//form[@id='login']" ) do
      fill_in 'Login'   , :with => username
      fill_in 'Password', :with => password
    end
    click_button 'Log In'
    current_url.should == expected_url
  end
  
  def log_out
    click_link 'log out'
  end
  
end