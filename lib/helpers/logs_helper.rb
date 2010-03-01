module LogsHelper
  
  helpers do
    # ---------------------------------------------------------------------------
    def user_name_for( ctx, user_id )
      return ctx[user_id] if ctx[user_id]
      user  = Wackamole::User.users_cltn.find_one( user_id, :fields => [:una] )
      value = user['una']
      ctx[user_id] = value
      value
    end

    # ---------------------------------------------------------------------------
    # Find feature context for log entry
    def context_for( ctx, feature_id )   
      return ctx[feature_id] if ctx[feature_id]
      feature = Wackamole::Feature.features_cltn.find_one( feature_id, :fields => [:ctl, :act, :ctx] )
      if feature
        if feature['ctl']
          value = "#{feature['ctl']}##{feature['act']}" 
        else
          value = feature['ctx']
        end
      else
        value = "Unknown"
      end
      ctx[feature_id] = value
      value
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
      return "n/a" unless host or host.empty?      
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
    def browser_class( browser )
      class_name = browser['name'].downcase
      if class_name == 'msie'
        version = browser['version'].match( /(\d)\.\d/ ).captures.first
        class_name = "ie_#{version.to_s}"
      elsif class_name == "n/a"
        class_name = 'unknown'
      end 
      class_name
    end
  end
end