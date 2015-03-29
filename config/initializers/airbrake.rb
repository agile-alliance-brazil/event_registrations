# encoding: UTF-8
require File.join(File.dirname(__FILE__), '00_app_config') unless defined?(APP_CONFIG)

if APP_CONFIG[:airbrake]
  Airbrake.configure do |config|
    config.api_key = APP_CONFIG[:airbrake][:access_key]
  end
end
