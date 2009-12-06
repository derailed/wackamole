class DateTime
  
  def to_date_id
    self.strftime( "%Y%m%d").to_i
  end
  
  # convert date to graph date scale
  def to_graph_date
    self.strftime( "%m/%d/%y")
  end  
end