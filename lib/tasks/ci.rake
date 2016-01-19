begin
  desc 'Task to run on CI: runs Konacha specs and RSpec specs'
  task ci: %i(rubocop brakeman spec)

  task default: :ci

  task :rubocop do
    sh 'bundle exec rubocop'
  end

  task :brakeman do
    sh 'bundle exec brakeman -z'
  end

rescue LoadError
  STDERR.puts("RSpec, Rubocop or Konacha isn't loaded! Either remove this rake task or ensure those are available.")
end
