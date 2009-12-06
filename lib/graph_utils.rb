module GraphUtils
  
  def license
    "JTAN82MSEQ9O.945CWK-2XOI1X0-7L"
  end
  
  # setup xml header
  def setup_header
    {
      "Content-Type"  => 'text/xml',
      "Cache-Control" => "no-cache, must-revalidate",
      "Pragma"        => "public"
    }
  end
  
  def time_series( date_ids )
    series = []
    date_ids.each do |date_id|
      series << date_id.to_s.to_graph_date
    end
    series
  end
  
  def to_series( date_ids, rows )
    series = []
    date_ids.each do |date_id|
      series << (rows[date_id] || 0).to_i
    end
    series
  end
  
  # Fetch collection of date_ids from a given days range
  def date_ranges( range )
    corpus_end   = DateTime.now
    corpus_start = corpus_end - range
    calc_date    = corpus_start
    time_series       = []  
    while calc_date <= corpus_end do   
      time_series << calc_date.to_date_id
      calc_date += 1
    end     
    time_series
  end  
end