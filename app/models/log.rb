# TODO - use dynamic stat finder
# TODO - need index on feature_id, user, type, tid, did
class Log
  include MongoMapper::Document
  
  belongs_to :feature, :foreign_key => 'fid'
  belongs_to :user   , :foreign_key => 'uid'

  # ---------------------------------------------------------------------------
  # Converts internal mole types to human readable
  def human_type
    case self.typ
      when Rackamole.perf  : "Performance"
      when Rackamole.fault : "Exception"
      else                   "Feature"
    end
  end
  
  # ---------------------------------------------------------------------------
  # Change ids to time
  def timestamp
    begin    
      date_tokens = self.did.match( /(\d{4})(\d{2})(\d{2})/ ).captures
      time_tokens = self.tid.match( /(\d{2})(\d{2})(\d{2})/ ).captures    
      time        = Time.utc( date_tokens[0], date_tokens[1], date_tokens[2], time_tokens[0], time_tokens[1], time_tokens[2] )
      return time.getlocal
    rescue
      nil
    end
  end
  
  # ---------------------------------------------------------------------------
  # Search filter key name map
  def self.field_map( key )
    case key.to_sym
      when :user    : :uid
      when :host    : :hos
      when :session : :ses
      when :params  : :par
      else            key
    end
  end
    
  # ---------------------------------------------------------------------------
  # Find top users...
  def self.find_top_users( filter )
    logs = nil
    elapsed = Benchmark::realtime do
      logs = self.collection.group( [:uid], filter.to_conds, 
        { :count => 0 }, 'function(obj,prev) { prev.count += 1}', true )
    end    
    puts "Time to find top users %d -- %5.4f secs" % [logs.size, elapsed]
    logs
  end

  # ---------------------------------------------------------------------------
  # Find top features for a given criteria
  def self.find_top_features( filter )
    res = nil
    elapsed = Benchmark::realtime do
      res = self.collection.group( [:fid], filter.to_conds, 
        { :count => 0 }, 'function(obj,prev) { prev.count += 1}', true )
    end    
    puts "Time to find top features %d -- %5.4f secs" % [res.size, elapsed]
    res
  end
    
#   # compute day counts for a given feature
#   def self.count_logs_for_feature( feature_id, from_date_id, type )
#     self.collection.group(
#         ['did'],
#         { :fid => feature_id, :did => { '$gte' =>  from_date_id }, :type => type },
#         { 'totals' => 0 },
#         "function( obj, prev ) { prev.totals++; }",
#         false
#     )    
#   end
# 
#   def self.count_logs_per_user( feature_ids, from_date_id, type )
#     self.collection.group(
#         ['una'],
#         { :fid => { '$in' => feature_ids }, :did => { '$gte' =>  from_date_id }, :type => type },
#         { 'totals' => 0 },
#         "function( obj, prev ) { prev.totals++; }",
#         false
#     )    
#   end
#     
#   # compute day counts for user for a given app
#   def self.count_logs_for_user( user, feature_ids, from_date_id, type )
#     self.collection.group(
#         ['did'],
#         { :fid => { '$in' => feature_ids }, :una => user, :did => { '$gte' =>  from_date_id }, :typ => type },
#         { 'totals' => 0 },
#         "function( obj, prev ) { prev.totals++; }",
#         false
#     )    
#   end
#   
#   # compute day counts for a given app
#   def self.count_logs_per_day( feature_ids, from_date_id, type )
#     conds = { :fid => { '$in' => feature_ids }, :did => { '$gte' =>  from_date_id }, :typ => type }
# puts conds.inspect    
#     self.collection.group(
#         ['did'],
#         conds,
#         { 'totals' => 0 },
#         "function( obj, prev ) { prev.totals++; }",
#         false
#     )    
#   end

end