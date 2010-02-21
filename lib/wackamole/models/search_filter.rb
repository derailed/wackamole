require 'chronic'

module Wackamole
  class SearchFilter
  
    attr_accessor :time_frame, :feature_id, :type, :browser_type, :search_terms, :hour

    # ---------------------------------------------------------------------------
    # Ctor
    def initialize
      reset!
    end

    # ---------------------------------------------------------------------------
    # Reset filter to defaults
    def reset!
      @feature_id   = -1
      @time_frame   = SearchFilter.time_frames.first
      @browser_type = SearchFilter.browser_types.first
      @type         = SearchFilter.mole_types.first
      @hour         = SearchFilter.hourlies.first
      @search_terms = ""
    end
  
    # ---------------------------------------------------------------------------
    # Available browsers
    def self.browser_types
      @browsers ||= [ 'All', 'Unknown', 'Firefox', 'Safari', 'MSIE 8.0', 'MSIE 7.0', 'MSIE 6.0', 'Opera', 'Chrome' ] 
    end
  
    # ---------------------------------------------------------------------------
    # Available time frames
    def self.time_frames
      @time_frames ||= ['today', '2 days', '1 week', '2 weeks', '1 month', '3 months', '6 months', '1 year' ]
    end

    # ---------------------------------------------------------------------------
    # Available hours    
    def self.hourlies
      @hourlies ||= ['all'] + (1..23).to_a
    end

    # ---------------------------------------------------------------------------
    # Collection of mole types
    def self.mole_types
      @types ||= %w[All Feature Perf Fault]
    end
  
    # ---------------------------------------------------------------------------
    # Set filter type  
    def mole_type( type )
      self.type = to_filter_type( type )
    end
    
    # ---------------------------------------------------------------------------
    # Find all features  
    def features
      rows = Feature.features_cltn.find().to_a
      features = rows.map { |f| [context_for(f), f['_id'].to_s] }   
      features.sort! { |a,b| a.first <=> b.first }
      features.insert( 0, ["All", -1] )
    end

    # ---------------------------------------------------------------------------
    # Retrieves feature context
    def context_for( f )
      return "#{f['ctl']}##{f['act']}" if f['ctl']
      f['ctx']
    end
  
    # ---------------------------------------------------------------------------
    # Fetch filter start date id
    def from_date_id
      start = Chronic.parse( time_frame + ( time_frame == SearchFilter.time_frames.first ? "" : " ago" ) )
      start.to_date_id
    end

    # ---------------------------------------------------------------------------
    # fetch time series from time frame
    def time_ids
      now          = Time.now
      start        = Chronic.parse( time_frame + ( time_frame == SearchFilter.time_frames.first ? "" : " ago" ) )
      corpus_end   = DateTime.new( now.year, now.month, now.day )
      corpus_start = DateTime.new( start.year, start.month, start.day )
    
      calc_date   = corpus_start
      time_series = []  
      while calc_date <= corpus_end do   
        time_series << calc_date.to_date_id
        calc_date += 1
      end     
      time_series
    end                  
  
    # ---------------------------------------------------------------------------
    # fetch time series from time frame
    def time_series    
      now          = Time.now
      start        = Chronic.parse( time_frame + ( time_frame == SearchFilter.time_frames.first ? "" : " ago" ) )
      corpus_end   = DateTime.new( now.year, now.month, now.day )
      corpus_start = DateTime.new( start.year, start.month, start.day )
    
      calc_date   = corpus_start
      time_series = []  
      while calc_date <= corpus_end do   
        time_series << calc_date.strftime( "%Y-%m-%d" )
        calc_date += 1
      end     
      time_series
    end                  
        
    # ---------------------------------------------------------------------------
    # Populate filter from request params
    def from_options( options )
      return unless options
      options.each_pair do |k,v|
        self.send( "#{k}=", v )
      end
    end
  
    # ---------------------------------------------------------------------------
    # Spews filter conditions
    def to_conds
      conds = {}
    
      # filter mole_types
      if type != 'All'
        conds[:typ] = map_mole_type( type )
      end
    
      if browser_type != 'All'
        conds["bro.name"] = browser_type
      end
    
      # filter mole_features
      unless feature_id.to_s == "-1"
        conds[:fid] = Mongo::ObjectID.from_string( feature_id )
      end
                    
      # filter by date
      time = Chronic.parse( time_frame + ( time_frame == SearchFilter.time_frames.first ? "" : " ago" ) )
      conds[:did] = { '$gte' => time.to_date_id.to_s }
      
      unless self.hour == 'all'
        now     = Time.now
        current = "%4d/%02d/%02d %02d:%02d:%02d" % [now.year, now.month, now.day, self.hour, 0, 0]    
        time = Chronic.parse( current ).utc
        conds[:tid] = /^#{"%02d"%time.hour}.+/
      end
      
      unless search_terms.empty?
        tokens = search_terms.split( ":" ).collect{ |c| c.strip }
        key    = tokens.shift
        if key
          if key == "user"
            users = Wackamole::User.users_cltn.find( { :una => Regexp.new( tokens.first ) }, :fields => ['_id'] )
            conds[field_map( 'user_id' )] = { '$in' => users.collect{ |u| u['_id'] } }
          elsif tokens.size == 2
            conds["#{field_map(key)}.#{tokens.first}"] = Regexp.new( tokens.last )
          elsif tokens.size == 1
            conds[field_map(key)] = Regexp.new( tokens.first )
          else
            raise "Unable to evaluate search terms"
          end
        end
      end
      conds
    end
    
    # ===========================================================================
    private
  
      # ---------------------------------------------------------------------------
      # Search filter key name map
      def field_map( key )
        field = Rackamole::Store::MongoDb.field_map[key.to_sym]
        raise "Unable to map attribute `#{key}" unless field
        field
      end
  
      def to_filter_type( type )
        case type
          when Rackamole.feature
            'Feature'
          when Rackamole.perf
            'Perf'
          when Rackamole.fault
            'Fault'
          else         
            raise "Invalid rackamole type `#{type}"
        end        
      end
      
      # Map named type to fixnum value
      def map_mole_type( type )
        case type
          when 'Feature' 
            Rackamole.feature
          when 'Perf'   
            Rackamole.perf
          when 'Fault'  
            Rackamole.fault
          else         
            raise "Invalid mole type `#{type}"
        end
      end
    
      # ---------------------------------------------------------------------------
      # Zeroed out now
      def now
        to_zero_hour( Time.now )
      end
  
      # Zeros out time info
      def to_zero_hour( time )
        Time.gm( time.year, time.month, time.day, 0, 0, 0 )
      end
  end
end