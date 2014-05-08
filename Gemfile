source 'http://rubygems.org'

gem 'rails', '=3.2.18' # Issue #61 - target 4.0.2
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
gem 'will_paginate', '=3.0.5'
gem 'omniauth', '=1.2.1'
gem 'omniauth-twitter', '=1.0.1'
gem 'omniauth-facebook', '=1.6.0'
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
  gem 'mysql2', '=0.3.15'
end

group :development do
  gem 'capistrano', '3.1.0', require: false
  gem 'capistrano-rails', '1.1.1', require: false
  gem 'capistrano-bundler', '1.1.2', require: false
  gem 'travis-lint', '=1.8.0'
  gem 'foreman', '=0.63.0'
end

def linux_only(require_as)
  RUBY_PLATFORM.include?('linux') && require_as
end

group :test do
  gem 'mocha', '=1.0.0', :require => false
  gem 'rb-inotify', '=0.9.0', :require => linux_only('rb-inotify')
  gem 'shoulda-matchers', '=2.5.0', :require => false
  gem 'factory_girl_rails', '=4.3.0'
  gem 'timecop', '=0.7.1'
end

group :development, :test do
  gem 'sqlite3', '=1.3.9'
  gem 'rspec-rails', '=2.14.2'
  gem 'guard-rspec', '=4.2.8'
  gem 'rb-fsevent', '=0.9.4'
  gem 'spork-rails', '=4.0.0'
  gem 'jasmine-jquery-rails', '=1.5.9' # 2.x requires jasmine 2.0 which is not yet supported by jasminerice
  gem 'guard-jasmine', '=1.19.0'
  gem 'jasminerice', '=0.0.10'
end
