begin
  desc "Task to run on CI: runs Konacha specs and RSpec specs"
  task :ci => [:spec, :'konacha:run']

  task :default => :ci
rescue LoadError
end
