module MissionHelper
  
  # ---------------------------------------------------------------------------
  # Assign status fg for application
  def assign_class( type, count, diff )
    clazz = case type
      when "faults"   : (diff > 0 ? "fault" : "")
      when "perfs"    : (diff > 0 ? "perf" : "")
      when "features" : (diff > 0 ? "active" : "inactive")
      else              ""
    end
    clazz
  end
  
  # ---------------------------------------------------------------------------
  # Computes count diff since last check point
  def compute_diff( app_name, env, type_name, count )
    old_count = find_report_count( app_name, env, type_name )        
    return (count - old_count) if( old_count )
    count
  end
  
  # ===========================================================================
  private
  
    # ---------------------------------------------------------------------------
    # Find report count for a given report
    def find_report_count( app, env, type )
      @old_reports.each do |report|
        next unless report['app'] == app      
        report['envs'].each_pair do |e, details|
          next unless e == env        
          details.each_pair do |type_name, count|
            return count if type_name == type
          end  
        end      
      end
      nil
    end
  
end