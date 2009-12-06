class Time  
  def to_date_id
    self.strftime( "%Y%m%d").to_i
  end
  
  def to_time_id
    "%02d%02d" % [self.hour, self.min]
  end
end