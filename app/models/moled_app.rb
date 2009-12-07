# # Rackamole puts all moled information for a given app and env into a single
# # mongo db instance.
# # This class retrieves all pertinent information about a given web application.
# require_dependency 'graph_utils'
# 
# class MoledApp
#   include GraphUtils
#   
#   def name
#     @name ||= Feature.find( :first, :fields => [:app] ).app
#   end
#   
#   def environment
#     @environment ||= Feature.find( :first, :fields => [:env] ).env
#   end
#   
#   # Retrieves all features
#   def features
#     Feature.all
#   end
#   
#   # Count all logs grouped by date from given start date    
#   def count_logs_from( range, type=nil )
#     time_series = date_ranges( range )
#  
#     conds = { 
#       :fid => { '$in'  => feature_ids.map{ |f| f.to_s } }, 
#       :did => { '$gte' => time_series.first }
#     }    
#     conds[:typ] = type if type
#     
#     counts = Log.collection.group(
#       ['did'],
#       conds,
#       { 'totals' => 0 },
#       "function( obj, prev ) { prev.totals++; }",
#       false )
#     results = time_series.inject( OrderedHash.new ) { |hash, date_id| hash[date_id.to_i] = 0;hash }
#     counts.each do |c|
#       results[c['did'].to_i] = c['totals'].to_i
#     end
#     results
#   end
#   
#   def count_features_from( from_date_id )
#     count_logs_from( from_date_id, Rackamole.feature )
#   end
# 
#   def count_perf_from( from_date_id )
#     count_logs_from( from_date_id, Rackamole.perf )
#   end
# 
#   def count_faults_from( from_date_id )
#     count_logs_from( from_date_id, Rackamole.fault )
#   end
#   
#   # Find all logs from a given date_id with optional mole info type
#   def logs_from( from_date_id, type=nil )
#     conds = { 
#       :fid => { '$in'  => feature_ids }, 
#       :did => { '$gte' => from_date_id }
#     }    
#     conds[:typ] = type if type
#     Log.find( :all, conds )
#   end  
#   
#   private
#   
#     # Retrieves all moled feature ids
#     def feature_ids
#       features = Feature.find( :all, :fields => ['_id'] ).to_a
#       features.map(&:id)
#     end
#   
# end