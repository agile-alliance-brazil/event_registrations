# frozen_string_literal: true

Spring.after_fork do
  if ENV['DEBUGGER_STORED_RUBYLIB']
    starter = ENV['BUNDLER_ORIG_RUBYOPT'][2..]
    load("#{starter}.rb")
  end
end
