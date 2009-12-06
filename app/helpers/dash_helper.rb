module DashHelper
  
  # Check for zeroed out series...
  def zeroed_series?( series )
    series.inject(0) { |res, s| res + s } == 0
  end
end