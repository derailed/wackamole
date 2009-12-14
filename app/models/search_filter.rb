require 'chronic'
require 'core_ext/time'

class SearchFilter
  
  attr_accessor :time_frame, :feature_id, :type, :browser_type, :search_terms

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
  # Collection of mole types
  def self.mole_types
    @types ||= %w[All Feature Performance Fault]
  end
  
  # ---------------------------------------------------------------------------
  # Find all features  
  def features
    features = Feature.features_cltn.find().to_a
    features = features.map { |f| [context_for(f), f['id']] } 
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
      # value = k.index( /_id$/) ? v.to_i : v
      self.send( "#{k}=", v )
    end
  end
  
  # ---------------------------------------------------------------------------
  # Spews filter conditions
  def to_conds
    conds = {}
    
    # filter mole_types
    if type != 'All'
      conds[:typ] = map_mole_types( type )
    end
    
    if browser_type != 'All'
      conds[:bro] = browser_type
    end
    
    # filter mole_features
    unless feature_id.to_s == "-1"
      conds['fid'] = feature_id
    end
                    
    # filter by date
    time = Chronic.parse( time_frame + ( time_frame == SearchFilter.time_frames.first ? "" : " ago" ) )
    conds['did'] = { '$gte' => time.to_date_id.to_s }
      
    if search_terms
      tokens = search_terms.split( ":" ).collect{ |c| c.strip }
      key    = tokens.shift
      if key
        if key == "user"
          users = User.users_cltn.find( { :una => Regexp.new( tokens.first ) }, :fields => ['_id'] )
          conds[field_map( key )] = { '$in' => users.collect{ |u| u['_id'].to_s } }
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
      case key.to_sym
        when :user    : :uid
        when :host    : :hos
        when :session : :ses
        when :params  : :par
        else            key
      end
    end
  
    # Map named type to fixnum value
    def map_mole_types( type )
      case type
        when 'Feature'     : Rackamole.feature
        when 'Performance' : Rackamole.perf
        when 'Fault'       : Rackamole.fault
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