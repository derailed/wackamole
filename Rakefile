# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.
begin
  require 'tasks/bones'
  Bones.setup
rescue LoadError
  begin
    load File.join(File.dirname(__FILE__), %w[tasks setup.rb] )
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'wackamole'

PROJ.name        = 'wackamole'
PROJ.authors     = 'Fernand Galiana'
PROJ.summary     = 'A companion web app to Rackamole'
PROJ.email       = 'fernand.galiana@gmail.com'
PROJ.url         = 'http://www.rackamole.com'
PROJ.version     = Wackamole::VERSION
PROJ.ruby_opts   = %w[-W0]
PROJ.readme      = 'README.rdoc'
PROJ.rcov.opts   = ["--sort", "coverage", "-T"]
PROJ.ignore_file = "*.log"
PROJ.spec.opts   << '--color'
PROJ.rdoc.include = %w[.rb]

# Dependencies
depend_on "mongo"                 , ">= 0.18.1"
depend_on "mongo_ext"             , ">= 0.18.1"
depend_on "agnostic-will_paginate", ">= 3.0.0"
depend_on "memcache-client"       , ">= 1.5.0"
depend_on "mongo_rack"            , ">= 0.0.1"
depend_on "main"                  , ">= 4.2.0"
depend_on "sinatra"               , ">= 0.9.4"
depend_on "mongo_rack"            , ">= 0.0.3"

# Rake
task :default => ['fixtures:load','spec:run']