require 'rubygems'
require 'sinatra'
require 'forwardable'
require 'rack/test'
require 'mongo'
require 'rackamole'
gem     'agnostic-will_paginate'
require 'will_paginate'
require 'forwardable'

require File.expand_path( File.join(File.dirname(__FILE__), %w[data fixtures]))
require File.expand_path( File.join(File.dirname(__FILE__), %w[.. lib wackamole]))

# BOZO !! To run test you'll need to start a mongo instance
# mongod --dbpath /data/wackamole/ --port 27777
Spec::Runner.configure do |config|
end