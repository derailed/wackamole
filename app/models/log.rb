class Log
  extend MongoBase, SingleForwardable
  
  def_delegators :logs_cltn, :find, :find_one
    
  # Pagination size
  def self.default_page_size() @page_size ||= 20; end
  
  # ---------------------------------------------------------------------------
  # Fetch all logs matching the given condition
  def self.paginate_logs( conds, page=1 )    
    matching = logs_cltn.find( conds )    
    WillPaginate::Collection.create( page, default_page_size, matching.count ) do |pager|
      pager.replace( logs_cltn.find( conds, 
        :sort  => [ ['did', 'desc'], ['tid', 'desc'] ],
        :skip  => (page-1)*default_page_size, 
        :limit => default_page_size ).to_a )
    end
  end
  
  # ---------------------------------------------------------------------------
  # Makes sure the correct indexes are set
  def self.ensure_indexes
    logs_cltn.create_index( :fid )
    logs_cltn.create_index( :uid )
    logs_cltn.create_index( :did )
    logs_cltn.create_index( :tid )
    logs_cltn.create_index( 
      [ 
        [:did, Mongo::DESCENDING], 
        [:tid, Mongo::DESCENDING] 
      ] 
    )
  end
    
end
