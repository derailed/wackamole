class DbsController < ApplicationController
  
  layout 'base'
  
  def index
    dbs      = MongoMapper.connection.database_info
    mole_dbs = dbs.keys.select{ |db| db =~ /^mole_/ }
    
    @dbs = OrderedHash.new
    mole_dbs.sort.each { |db| @dbs[db] = dbs[db] }
  end
end