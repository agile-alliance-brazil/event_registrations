begin
  desc "Task to run on CI: runs Konacha specs and RSpec specs"
  task :ci => [:rubocop, :spec, :'konacha:run']

  task :default => :ci

  task :rubocop do
    sh 'bundle exec rubocop'
  end
rescue LoadError
end
