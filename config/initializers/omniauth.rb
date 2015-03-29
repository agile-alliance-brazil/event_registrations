OmniAuth.config.logger = Rails.logger

fail "Twitter key/secret is not configured in config/config.yml file not found. Please check config/config.example for a sample" unless APP_CONFIG[:twitter]
fail "Facebook key/secret is not configured in config/config.yml file not found. Please check config/config.example for a sample" unless APP_CONFIG[:facebook]
fail "Github key/secret is not configured in config/config.yml file not found. Please check config/config.example for a sample" unless APP_CONFIG[:github]
fail "Submission system key/secret is not configured in config/config.yml file not found. Please check config/config.example for a sample" unless APP_CONFIG[:submission_system]

require File.expand_path('lib/omniauth/strategies/submission_system', Rails.root)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :github, APP_CONFIG[:github][:key], APP_CONFIG[:github][:secret]
  provider :twitter, APP_CONFIG[:twitter][:key], APP_CONFIG[:twitter][:secret]
  provider :facebook, APP_CONFIG[:facebook][:key], APP_CONFIG[:facebook][:secret]
  provider :submission_system, APP_CONFIG[:submission_system][:key], APP_CONFIG[:submission_system][:secret], :client_options => {:ssl => {:ca_path => '/etc/ssl/certs'}}
  # require 'openid/store/filesystem'
  # provider :openid, :store => OpenID::Store::Filesystem.new(File.join(Rails.root, '/tmp'))
end
