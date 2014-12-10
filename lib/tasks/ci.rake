begin
  desc "Task to run on CI: runs RSpec specs"
  task :ci => [:spec]

  task :default => :ci
rescue LoadError
end