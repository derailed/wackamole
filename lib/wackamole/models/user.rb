require 'will_paginate/collection'

module Wackamole
  class User
  
    def self.logs_cltn()  Wackamole::Control.collection( 'logs' ) ;  end  
    def self.users_cltn() Wackamole::Control.collection( 'users' );  end
  
    # Pagination size
    def self.default_page_size() @page_size ||= 20; end
  
    # ---------------------------------------------------------------------------
    # Find all users matching criteria and returns pagination collection
    def self.paginate_tops( conds, page=1, page_size=default_page_size )
      tops = logs_cltn.group( [:uid], conds, { :count => 0 }, 'function(obj,prev) { prev.count += 1}', true )    
      users = []
      tops.sort{ |a,b| b['count'] <=> a['count'] }.each do |row|
        users << { :uid => row['uid'], :total => row['count'].to_i, :details => [] }
      end
    
      WillPaginate::Collection.create( page, page_size, users.size ) do |pager|      
        offset = (page-1)*page_size
        result = users[offset...(offset+page_size)]
        result.each do |u|
          user = users_cltn.find_one( u[:uid] ) #, :fields => [:una] )
          raise "Unable to find user with id `#{u[:uid].inspect}" unless user
          u[:name] = user['una']
        end
        pager.replace( result )
      end
    end
  
    # ---------------------------------------------------------------------------
    # Make sure indexes are setup for users
    def self.ensure_indexes!
      indexes       = users_cltn.index_information
      created_count = 0
      
      unless indexes.has_key?( :una )
        users_cltn.create_index( :una )
        created_count += 1
      end
      created_count
    end
  end
end