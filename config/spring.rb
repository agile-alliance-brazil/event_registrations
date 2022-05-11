# frozen_string_literal: true

Spring.after_fork do
  if ENV['DEBUGGER_STORED_RUBYLIB']
    starter = ENV.fetch('BUNDLER_ORIG_RUBYOPT', nil)[2..]
    load("#{starter}.rb")
  end
end
