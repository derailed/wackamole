class User
  include MongoMapper::Document

  # Relationships...
  has_many :logs
  
end