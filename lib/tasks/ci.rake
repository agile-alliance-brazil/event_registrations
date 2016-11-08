begin
  desc 'Task to run on CI: runs Konacha specs and RSpec specs'
  task ci: %i(rubocop brakeman spec codeclimate-test-reporter)

  task default: :ci

  task :rubocop do
    sh 'bundle exec rubocop'
  end

  task :brakeman do
    sh 'bundle exec brakeman -z'
  end

  task :'codeclimate-test-reporter' do
    sh 'if [[ -n ${CODECLIMATE_REPO_TOKEN} ]]; then bundle exec codeclimate-test-reporter; fi'
  end
rescue LoadError
  STDERR.puts("RSpec, Rubocop or Konacha isn't loaded! Either remove this rake task or ensure those are available.")
end
