# require 'ostruct'
# 
# class Logs
#   # extend Forwardable  
#   # def_delegator :@cursor, :each
#     
#   def self.paginate( selector, opts={} )
#     find( selector, opts )
#   end
#   
#   def self.find( selector, opts={} )
#     Logs.new( App.logs_cltn.find( selector, opts ) )
#   end
#   
#   def initialize( cursor )
#     @cursor = cursor
#   end
#   
#   def each
#     num_returned = 0
#     while @cursor.send( :more? ) && (@cursor.limit <= 0 || num_returned < @cursor.limit)
#       obj = OpenStruct.new( @cursor.next_object )
# puts obj.to_yaml
#       yield obj
#       num_returned += 1
#     end
#     num_returned
#   end
#   
#   def empty?
#     @cursor.count == 0
#   end
#   
#   def length
#     @cursor.limit
#   end
#   
#   # Pagination
#   def previous_page
#     current_page > 1 ? (current_page - 1) : nil
#   end
#   
#   def next_page
#     current_page < total_pages ? (current_page + 1) : nil    
#   end
#   
#   def current_page
#     @cursor.skip/@cursor.limit
#   end
#   
#   def total_entries
#     @cursor.count
#   end
#   
#   def total_pages
#     @cursor.count/@cursor.limit
#   end
#   
#   def offset
#     @cursor.skip
#   end
#         
#   def to_a
#     @cursor.to_a
#   end
# end