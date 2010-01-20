class DateTime
  
  # ---------------------------------------------------------------------------
  # Convert a datetime to an id ie => 20100101
  def to_date_id
    self.strftime( "%Y%m%d").to_i
  end  
end