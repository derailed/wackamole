function show_logs( url, category, date_id )
{
  console.log( url );
  console.log( category );
  console.log( date_id );
  popup_logs( url + "?category=" + category + "&amp;date_id=" + date_id );
  
}

// popup logs window
function popup_logs( url )
{
  win = window.open( url, 'Logs', "height=600,width=1000,status=1,resizable=1,scrollbars=1,location=1,menubar=0,toolbar=0" );
  win.focus();
}