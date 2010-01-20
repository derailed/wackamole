require 'forwardable'

module Wackamole
  class Log
    extend ::SingleForwardable
  
    def self.logs_cltn() Wackamole::Control.collection( 'logs' ); end
  
    def_delegators :logs_cltn, :find, :find_one
    
    # Pagination size
    def self.default_page_size() @page_size ||= 20; end
  
    # ---------------------------------------------------------------------------
    # Fetch all logs matching the given condition
    def self.paginate( conds, page=1, page_size=default_page_size )
      matching = logs_cltn.find( conds )    
      WillPaginate::Collection.create( page, page_size, matching.count ) do |pager|
        pager.replace( logs_cltn.find( conds, 
          :sort  => [ ['did', 'desc'], ['tid', 'desc'] ],
          :skip  => (page-1)*page_size, 
          :limit => page_size ).to_a )
      end      
    end
  
    # ---------------------------------------------------------------------------
    # Makes sure the correct indexes are set
    def self.ensure_indexes!
      indexes       = logs_cltn.index_information
      created_count = 0
            
      [:fid, :uid, :did, :tid].each do |name|
        unless indexes.has_key?( "#{name}_1" )
          logs_cltn.create_index( name )
          created_count += 1
        end
      end
      unless indexes.has_key?( 'did_-1_tid_-1' )
        logs_cltn.create_index( [ [:did, Mongo::DESCENDING], [:tid, Mongo::DESCENDING] ] ) 
        created_count += 1
      end
      created_count
    end
  end    
end
