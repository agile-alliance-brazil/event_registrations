source 'https://rubygems.org'
ruby '2.3.0'

def linux_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /linux/ ? require_as : false
end

# Mac OS X
def darwin_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /darwin/ ? require_as : false
end

gem 'rails', '~> 4.2'
gem 'brcpfcnpj', '~> 3.3.0'
gem 'state_machine', '~> 1.2.0'
gem 'haml', '~> 4.0'
gem 'formtastic', '~> 3.1.3'
gem 'airbrake', '~> 5.0'
gem 'localized_country_select', '~> 0.9.11'
gem 'cancancan', '~> 1.10'
gem 'rake'
gem 'will_paginate', '~> 3.1'
gem 'omniauth', '~>1.3'
gem 'hashie', '3.4.3' # TODO: Weird rubygems error for 3.4.4
gem 'omniauth-twitter', '~>1.2'
gem 'omniauth-facebook', '~>3.0'
gem 'omniauth-github', '~>1.1'
gem 'aws-ses', '~> 0.6.0', require: 'aws/ses'
gem 'faker'
gem 'pagseguro-oficial'
gem 'money-rails'

gem 'jquery-rails'
gem 'therubyracer', '~> 0.12', platforms: :ruby
gem 'sass-rails'
gem 'sass'

gem 'coffee-rails', '~> 4.1'
gem 'yui-compressor', '~> 0.12', require: 'yui/compressor'
gem 'bootstrap-sass', '~> 3.3'
gem 'autoprefixer-rails', '~> 6.2'

gem 'mysql2', '~> 0.4'

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'guard-rspec'
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'terminal-notifier-guard', require: darwin_only('terminal-notifier-guard')
  gem 'rb-inotify', require: linux_only('rb-inotify')
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'sprockets-rails'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'selenium-webdriver'
  gem 'rubocop', require: false
  gem 'guard-rubocop'
  gem 'metric_fu'
  gem 'annotate'
  gem 'database_cleaner'
  gem 'byebug', require: false
  gem 'dotenv-rails', require: false
  gem 'parser', '>= 2.3.0.pre.6'
  gem 'brakeman', require: false
end

group :development do
  gem 'capistrano', '3.5.0', require: false
  gem 'net-ssh', '~> 3.0'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rvm', require: false
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
  gem 'webmock'
end
