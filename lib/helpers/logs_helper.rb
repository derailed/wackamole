module LogsHelper
  
  helpers do
    # ---------------------------------------------------------------------------
    def user_name_for( user_id )
      user = Wackamole::User.users_cltn.find_one( user_id )
      user['una']
    end
  
    # ---------------------------------------------------------------------------
    def feature_name_for( feature_id )
      feature = Wackamole::Feature.features_cltn.find_one( feature_id )
      if feature['ctx']
        return feature['ctx']
      end
      "#{feature['ctrl']}##{feature['act']}"
    end
  
    # ---------------------------------------------------------------------------
    def human_type( type )
      case type
        when Rackamole.perf
          "Performance"
        when Rackamole.fault
          "Exception"
        else 
          "Feature"
      end
    end
  
    # ---------------------------------------------------------------------------
    # Change ids to time
    def timestamp_for( log )
      begin    
        date_tokens = log['did'].match( /(\d{4})(\d{2})(\d{2})/ ).captures
        time_tokens = log['tid'].match( /(\d{2})(\d{2})(\d{2})/ ).captures    
        time        = Time.utc( date_tokens[0], date_tokens[1], date_tokens[2], time_tokens[0], time_tokens[1], time_tokens[2] )
        return time.getlocal.strftime( "%m/%d/%y %H:%M:%S")
      rescue
        ;
      end
      "N/A"
    end

    # ---------------------------------------------------------------------------
    # Find feature context for log entry
    def context_for( feature_id )
      feature = Wackamole::Feature.features_cltn.find_one( feature_id )
      if feature['ctl']
        return "#{feature['ctl']}##{feature['act']}"
      end
      feature['ctx']
    end
  
    # ---------------------------------------------------------------------------
    # Converts mole type to big icon
    def mole_type_icon( type )
      case type
        when Rackamole.perf 
          "perf_big.png"
        when Rackamole.fault
          "fault_big.png"
        else                     
          "info_big.png"
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
    def request_time( req_time )
      begin
        "%4.2f" % req_time
      rescue
        "N/A"
      end
    end
    
    # ---------------------------------------------------------------------------
    # Change log color depending on type
    def row_class_for( type )
      case type
        when Rackamole.feature
          "feature"
        when Rackamole.perf 
          "perf"
        when Rackamole.fault
          "fault"
      end
    end
  
    # ---------------------------------------------------------------------------
    # Setup browser icon indicator
    def browser_icon( browser )
      img_name = browser
      img_name = "unknown_browser" if img_name.nil? or img_name == "N/A"
      image_tag "browsers/#{img_name.to_s.downcase.gsub( /\\/, '')}.png", :size => "20x20"    
    end
  end
end