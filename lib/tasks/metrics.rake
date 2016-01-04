begin
  require 'metric_fu'
  MetricFu::Configuration.run do |config|
    config.configure_metric(:rcov) do |rcov|
      rcov.enable
      rcov.activate
      # config.rcov[:test_files] = ['spec/**/*_spec.rb']
      # config.rcov[:rcov_opts] << "-Ispec" # Needed to find spec_helper
    end
  end
rescue LoadError
  STDERR.puts("Metric fu isn't loaded! Either remove this rake task or ensure MetricFu is loaded.")
end
