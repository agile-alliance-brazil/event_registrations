source 'https://rubygems.org'
ruby '2.3.1'

def linux_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /linux/ ? require_as : false
end

# Mac OS X
def darwin_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /darwin/ ? require_as : false
end

gem 'airbrake', '~> 6.0'
gem 'autoprefixer-rails', '~> 6.2'

gem 'aws-ses', '~> 0.6.0', require: 'aws/ses'
gem 'bootstrap-sass', '~> 3.3'
gem 'brcpfcnpj', '~> 3.3.0'
gem 'cancancan', '~> 1.10'
gem 'coffee-rails', '~> 4.1'
gem 'faker'
gem 'formtastic', '~> 3.1.3'
gem 'haml', '~> 4.0'
gem 'httparty'
gem 'jquery-rails'
gem 'localized_country_select', '~> 0.9.11'
gem 'money-rails'
gem 'mysql2', '~> 0.4'
gem 'omniauth', '~>1.3'
gem 'omniauth-facebook', '~>4.0'
gem 'omniauth-github', '~>1.1'
gem 'omniauth-twitter', '~>1.2'
gem 'pagseguro-oficial'
gem 'rails', '~> 4.2'
gem 'rake'
gem 'sass'
gem 'sass-rails'
gem 'state_machine', '~> 1.2.0'
gem 'therubyracer', '~> 0.12', platforms: :ruby
gem 'will_paginate', '~> 3.1'
gem 'yui-compressor', '~> 0.12', require: 'yui/compressor'

group :development, :test do
  gem 'annotate'
  gem 'brakeman', require: false
  gem 'byebug', require: false
  gem 'database_cleaner'
  gem 'dotenv-rails', require: false
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'metric_fu'
  gem 'parser', '>= 2.3.0.pre.6'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'rb-inotify', require: linux_only('rb-inotify')
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'selenium-webdriver'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'sprockets-rails'
  gem 'sqlite3'
  gem 'terminal-notifier-guard', require: darwin_only('terminal-notifier-guard')
end

group :development do
  gem 'capistrano', '3.8.0', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-git-with-submodules', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  gem 'foreman'
  gem 'net-ssh', '~> 3.0'
  gem 'pry'
  gem 'travis-lint'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'mocha', require: false
  gem 'shoulda-matchers', require: false
  gem 'simplecov'
  gem 'timecop'
  gem 'webmock'
end
