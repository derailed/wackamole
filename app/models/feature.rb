class Feature
  include MongoMapper::Document
  
  key :app
  key :env
  key :ctx
  key :ctl
  key :act
  
  has_many :logs

  # ---------------------------------------------------------------------------
  # Figures add feature context name depending on ac scheme or plain path
  def context
    if self.ctl
      return "#{self.ctl}##{self.act}"
    end
    self.ctx
  end
    
end