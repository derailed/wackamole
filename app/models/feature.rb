class Feature
  
  def self.logs_cltn()     @logs     ||= Mongo::Control.collection( 'logs' ) ;  end  
  def self.features_cltn() @features ||= Mongo::Control.collection( 'features' );  end  
  
  # Pagination size
  def self.default_page_size() @page_size ||= 20; end
  
  # ---------------------------------------------------------------------------
  # Find the app name and env for the features collection
  # NOTE: Assumes 1 moled app per db...
  def self.get_app_info
    feature = features_cltn.find_one( {}, :fields => [:app, :env] )
    return nil, nil unless feature 
    return feature['app'], feature['env']
  end
  
  # ---------------------------------------------------------------------------
  # Paginate top features
  def self.paginate_top_features( conds, page=1 )
    tops = logs_cltn.group( [:fid], conds, { :count => 0 }, 'function(obj,prev) { prev.count += 1}', true )
    
    features = []
    tops.sort{ |a,b| b['count'] <=> a['count'] }.each do |row|
      features << { :fid => row['fid'], :total => row['count'].to_i }
    end
    
    WillPaginate::Collection.create( page, default_page_size, features.size ) do |pager|      
      offset = (page-1)*default_page_size
      result = features[offset...(offset+default_page_size)]
      result.each do |u|
        feature = features_cltn.find_one( u[:fid] )
        u[:name] = feature
      end
      pager.replace( result )
    end
  end
  
  # ---------------------------------------------------------------------------
  # Make sure indexes are setup for users
  def self.ensure_indexes
    features_cltn.create_index( :ctx )
    features_cltn.create_index( 
      [ 
        [:ctl, Mongo::ASCENDING], 
        [:act, Mongo::ASCENDING] 
      ]
    )
  end
  
end
