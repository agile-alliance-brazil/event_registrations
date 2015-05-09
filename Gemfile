source 'http://rubygems.org'
ruby '1.9.3'

def linux_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /linux/ ? require_as : false
end
# Mac OS X
def darwin_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /darwin/ ? require_as : false
end

gem 'rails', '=4.2.1'
gem 'seed-fu', '=2.3.5'
gem 'brhelper', '=3.3.0'
gem 'brcpfcnpj', '=3.3.0'
gem 'validates_existence', '=0.9.2'
gem 'state_machine', '=1.2.0'
gem 'haml', '=4.0.6'
gem 'formtastic', '=3.1.3'
gem 'airbrake', '=4.1.0'
gem 'localized_country_select', '=0.9.11'
gem 'cancan', '=1.6.10'
gem 'rake'
gem 'will_paginate', '=3.0.7'
gem 'omniauth', '=1.2.2'
gem 'omniauth-twitter', '=1.2.0'
gem 'omniauth-facebook', '=2.0.1'
gem 'omniauth-github', '=1.1.2'
gem 'aws-ses', '=0.6.0', require: 'aws/ses'
gem 'faker'
gem 'pagseguro-oficial'

gem 'jquery-rails', '=4.0.3'
gem 'therubyracer', '=0.12.2', platforms: :ruby
gem 'sass-rails', '=5.0.3'

gem 'coffee-rails', '=4.1.0'
gem 'yui-compressor', '=0.12.0', require: 'yui/compressor'

group :production, :travis do
  gem 'mysql2', '=0.3.18'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'terminal-notifier-guard', require: darwin_only('terminal-notifier-guard')
  gem 'rb-inotify', require: linux_only('rb-inotify')
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'konacha'
  gem 'sprockets', '< 3.0' # Konacha 3.3.0 cannot handle sprockets 3.0 yet
  gem 'guard-konacha-rails'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'selenium-webdriver'
  gem 'rubocop', require: false
  gem 'guard-rubocop'
  gem 'metric_fu'
end

group :development do
  gem 'capistrano', '=3.4.0', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'travis-lint'
  gem 'foreman'
  gem 'pry'
end

group :test do
  gem 'mocha', require: false
  gem 'shoulda-matchers', require: false
  gem 'factory_girl_rails'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
  gem 'simplecov', require: false
  # gem 'webmock'
  # gem 'vcr'
end
