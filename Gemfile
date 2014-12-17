source 'http://rubygems.org'
ruby '1.9.3'

gem 'rails', '=3.2.21' # Issue #61 - target 4.0.2
gem 'inherited_resources', '=1.4.1'
gem 'seed-fu', '=2.3.0'
gem 'brhelper', '=3.3.0'
gem 'brcpfcnpj', '=3.3.0'
gem 'validates_existence', '=0.8.0'
gem 'state_machine', '=1.2.0'
gem 'haml', '=4.0.5'
gem 'formtastic', '=2.2.1'
gem 'airbrake', '=3.1.16'
gem 'cancan', '=1.6.10'
gem 'jquery-rails', '=3.1.0'
gem 'rake', '=10.2.1'
gem 'will_paginate', '=3.0.7'
gem 'omniauth', '=1.2.1'
gem 'omniauth-twitter', '=1.0.1'
gem 'omniauth-facebook', '=2.0.0'
gem 'omniauth-github', '=1.1.1'
gem 'aws-ses', '=0.5.0', :require => 'aws/ses'

gem 'localized_country_select', '=0.9.7'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'therubyracer', '=0.12.1', :platforms => :ruby
  gem 'sass-rails',   '=3.2.6' # 4.0.1 requires rails 4
  gem 'coffee-rails', '=3.2.2' # 4.0.1 requires rails 4
  gem 'yui-compressor', '=0.12.0'
end

group :production, :travis do
  gem 'mysql2', '=0.3.17'
end

group :development do
  gem 'capistrano', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'travis-lint'
  gem 'foreman'
end

def linux_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /linux/ ? require_as : false
end
# Mac OS X
def darwin_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /darwin/ ? require_as : false
end

group :test do
  gem 'mocha', require: false
  gem 'shoulda-matchers', require: false
  gem 'factory_girl_rails'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
end

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails', '=2.99.0'
  gem 'guard-rspec'
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'terminal-notifier-guard', require: darwin_only('terminal-notifier-guard')
  gem 'rb-inotify', require: linux_only('rb-inotify')
  gem 'spork-rails', '=4.0.0'
  gem 'jasmine-jquery-rails', '=1.5.9' # 2.x requires jasmine 2.0 which is not yet supported by jasminerice
  gem 'guard-jasmine', '=1.19.0'
  gem 'jasminerice', '=0.0.10'
end
