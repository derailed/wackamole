function truncate(str, limit) 
{
  var bits, i;
  bits = str.split('');
  if (bits.length > limit) {
    for (i = bits.length - 1; i > -1; --i) {
      if (i > limit) {
        bits.length = i;
      }
      else if (' ' === bits[i]) {
        bits.length = i;
        break;
      }
    }
    bits.push('...');
  }
  return bits.join('');
}

// Graphs...
function gen_load( name, value, total )
{
  var p      = Raphael( name, 300, 20 );
  var range  = Math.ceil( ((value/total)*100)/10 );
  var x      = 2;
  var y      = 2;
  var spacer = 5;
      
  for( var i=1; i <= range; i++ )
  {
    var l = p.rect( x, y, 10, 16, 2 );
    l.attr( 'fill', 'green' );
    l.attr( 'gradient', '45-#0f0-#fff' );
    l.attr( 'stroke-width', 0 );
    x += 10 + spacer;

  }
  var text = p.text( 230, 10, Math.ceil((value/total)*100) + '% (' + value + " of " + total + ')' );
  text.attr( 'fill'     , '#434343' );  
  text.attr( 'font-size', 15 );      
}

function gen_heat_map( url, id, series, symbol, xs, ys, axisx, axisy )
{
  var r = Raphael( id );
  var urls = [];
  
  for( hour in xs ) { 
    var u = url + hour + "/";
    urls[hour] = u;
  }
    
  var chart = r.g.dotchart(0, -10, 620, 60, xs, ys, series, {href: urls, symbol: symbol, max: 10, heat: true, axis: "0 0 1 0", axisxstep: 23, axisystep: 1, axisxlabels: axisx, axisxtype: " ", axisytype: " ", axisylabels: axisy})
  
  chart.hover( function () {
      this.tag = this.tag || r.g.tag(this.x, this.y, this.value, 0, this.r + 2).insertBefore(this);
      this.tag.show();
    }, 
    function () {
      this.tag && this.tag.hide();
    }
  );
  
  chart.click( function() {
    // this.tag = this.tag || r.g.tag(this.x, this.y, this.value, 0, this.r + 2).insertBefore(this);
    // console.log( "Clicked url " + this.href );
    // return false;
  }) 
}