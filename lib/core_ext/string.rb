# Override ruby string and inject to utils...
class String
    
  # assuming 09/02/08 string format
  def to_date_id
    tokens = self.split( "/" )
    raise "invalid date format" if tokens.empty? or tokens.size > 3
    "#{tokens[2]}#{tokens[0]}#{tokens[1]}".to_i 
  end
  
  def to_graph_date
    tokens = self.to_s.match( /(\d{4})(\d{2})(\d{2})/ ).captures 
    [tokens[1], tokens[2], tokens[0]].join( '/')
  end
end