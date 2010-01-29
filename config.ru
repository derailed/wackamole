require 'sinatra'    
require File.join(File.dirname(__FILE__), %w[lib app.rb])
Sinatra::Application.run! :port => 7777, :environment => 'production'