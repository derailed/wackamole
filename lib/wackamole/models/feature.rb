module Wackamole
  class Feature
  
    def self.logs_cltn()     Wackamole::Control.collection( 'logs' ) ;  end  
    def self.features_cltn() Wackamole::Control.collection( 'features' );  end  
  
    # Pagination size
    def self.default_page_size() @page_size ||= 20; end
  
    # ---------------------------------------------------------------------------
    # Find the app name and env for the features collection
    # NOTE: Assumes 1 moled app per db...
    def self.get_app_info
      feature = features_cltn.find_one( {}, :fields => [:app, :env] )
      raise "Unable to find a single feature in db `#{features_cltn.db.name}" unless feature 
      { :app_name => feature['app'], :stage => feature['env'] }
    end
  
    # ---------------------------------------------------------------------------
    # Paginate top features
    def self.paginate_tops( conds, page=1, page_size=default_page_size )
      tops = logs_cltn.group( [:fid], conds, { :count => 0 }, 'function(obj,prev) { prev.count += 1}' )
    
      all_features = features_cltn.find( {}, :fields => [:_id] )
      feature_ids  = all_features.map{ |f| f['_id'] }
      total_features = []
      tops.each do |row|
        total_features << row
        feature_ids.delete( row['fid'] )
      end
      feature_ids.each { |f| total_features << {'fid' => f, 'count' => 0} }

      features = []
      total_features.sort{ |a,b| b['count'] <=> a['count'] }.each do |row|
        features << { :fid => row['fid'], :total => row['count'].to_i }
      end
    
      WillPaginate::Collection.create( page, page_size, features.size ) do |pager|
        offset = (page-1)*page_size
        result = features[offset...(offset+page_size)]
        result.each do |u|
          feature = features_cltn.find_one( u[:fid] )
          u[:name] = feature
        end
        pager.replace( result )
      end
    end
  
    # ---------------------------------------------------------------------------
    # Make sure indexes are setup for users
    def self.ensure_indexes!
      indexes       = features_cltn.index_information
      created_count = 0

      [:ctx].each do |name|
        unless indexes.has_key?( "#{name}_1" )
          features_cltn.create_index( name ) 
          created_count += 1
        end
      end
      unless indexes.has_key?( 'app_1_env_1' )
        features_cltn.create_index( 
          [ 
            [:app, Mongo::ASCENDING], 
            [:env, Mongo::ASCENDING] 
          ]
        )
        created_count += 1
      end      
      unless indexes.has_key?( 'ctl_1_act_1' )
        features_cltn.create_index( 
          [ 
            [:ctl, Mongo::ASCENDING], 
            [:act, Mongo::ASCENDING] 
          ],
          true
        )
        created_count += 1
      end
      created_count
    end
  end
end