require File.expand_path( File.join( File.dirname(__FILE__) , %w[.. data fixtures] ) )

namespace :fixtures do

  # A prerequisites task that all other tasks depend upon
  task :prereqs

  desc 'Populate fixture data'
  task :load do |t|
    Fixtures.new.populate    
  end  

# task 'gem:release' => 'svn:create_tag'
end

