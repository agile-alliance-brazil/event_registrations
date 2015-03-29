begin
  require 'metric_fu'
  MetricFu::Configuration.run do |config|
    config.rcov[:test_files] = ['spec/**/*_spec.rb']
    config.rcov[:rcov_opts] << "-Ispec" # Needed to find spec_helper
    config.metrics -= [:rails_best_practices]
  end
rescue LoadError
  STDERR.puts("Metric fu isn't loaded! Either remove this rake task or ensure MetricFu is loaded.")
end