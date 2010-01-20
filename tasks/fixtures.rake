namespace :fixtures do

  # A prerequisites task that all other tasks depend upon
  task :prereqs

  desc 'Populate fixture data'
  task :load do |t|
    Fixtures.load_data    
  end  

# task 'gem:release' => 'svn:create_tag'
end

