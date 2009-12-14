class User
  
  def self.logs_cltn()  @logs  ||= Mongo::Control.collection( 'logs' ) ;  end  
  def self.users_cltn() @users ||= Mongo::Control.collection( 'users' );  end
  
  # Pagination size
  def self.default_page_size() @page_size ||= 20; end
  
  # ---------------------------------------------------------------------------
  # Find all users matching criteria and returns pagination collection
  def self.paginate_top_users( conds, page=1 )
    tops = logs_cltn.group( [:uid], conds, { :count => 0 }, 'function(obj,prev) { prev.count += 1}', true )    
    
    users = []
    tops.sort{ |a,b| b['count'] <=> a['count'] }.each do |row|
      users << { :uid => row['uid'], :total => row['count'].to_i, :details => [] }
    end
    
    WillPaginate::Collection.create( page, default_page_size, users.size ) do |pager|      
      offset = (page-1)*default_page_size
      result = users[offset...(offset+default_page_size)]
      result.each do |u|
        user = users_cltn.find_one( u[:uid], :fields => [:una] )
        u[:name] = user['una']
      end
      pager.replace( result )
    end
  end
  
  # ---------------------------------------------------------------------------
  # Make sure indexes are setup for users
  def self.ensure_indexes
    users_cltn.create_index( :una )
  end
  
end