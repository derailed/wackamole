module LogsHelper

  # ---------------------------------------------------------------------------
  # Converts mole type to big icon
  def mole_type_icon( type )
    case type
      when Rackamole.perf    : "perf_big.png"
      when Rackamole.fault   : "fault_big.png"
      else                     "info_big.png"
    end
  end
  
  # ---------------------------------------------------------------------------
  # Converts hash to string
  def dump_hash( hash )
    content = []
    hash.each_pair do |k,v|
      content << content_tag( :span, "#{k} -> #{v}" )
    end
    content.join( "" )
  end
     
  # ---------------------------------------------------------------------------
  # Trim out extra host info if any
  def format_host( host )    
    return host.split( "." ).first if host.index( /\./ )
    host
  end
   
  # ---------------------------------------------------------------------------
  # Check if request time is available
  def request_time( log )
    begin
      "%4.2f" % log.rti
    rescue
      "N/A"
    end
  end
    
  # ---------------------------------------------------------------------------
  # Change log color depending on type
  def row_class_for( type )
    case type
      when Rackamole.feature : "feature"
      when Rackamole.perf    : "perf"
      when Rackamole.fault   : "fault"
    end
  end
  
  # ---------------------------------------------------------------------------
  # Setup browser icon indicator
  def browser_icon( log )
    img_name = log.bro
    img_name = "unknown_browser" if img_name.nil? or img_name == "N/A"
    image_tag "/images/browsers/#{img_name.to_s.downcase.gsub( /\\/, '')}.png", :size => "20x20"    
  end
  
end