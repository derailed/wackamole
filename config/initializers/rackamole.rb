require 'rackamole'
require 'mongo_mapper'

# Specifies wackamole mongo connection params
# MUSTDO - Specify a database name - one db per app per env recommended
MongoMapper.connection = Mongo::Connection.new( 'localhost', 27017, :logger => RAILS_DEFAULT_LOGGER )
MongoMapper.database   = 'moled_fred_test_mdb'