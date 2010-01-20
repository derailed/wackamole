module FeaturesHelper
  
  helpers do
    # ---------------------------------------------------------------------------
    # Find feature context for log entry
    def display_context( feature )
      if feature['ctl']
        return "#{feature['ctl']}##{feature['act']}"
      end
      feature['ctx']
    end      
  end
end