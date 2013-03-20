source 'http://rubygems.org'

gem 'rails', '=3.2.13'
gem 'inherited_resources', '=1.3.1'
gem 'seed-fu', '=2.2.0'
gem 'brhelper', '=3.3.0'
gem 'brcpfcnpj', '=3.3.0'
gem 'validates_existence', '=0.8.0'
gem 'state_machine', '=1.1.2'
gem 'haml', '=4.0.0'
gem 'formtastic', '=2.2.1'
gem 'airbrake', '=3.1.8'
gem 'cancan', '=1.6.9'
gem 'jquery-rails', '=2.2.1'
gem 'rake', '=10.0.3'
gem 'will_paginate', '=3.0.4'
gem 'omniauth', '=1.1.3'
gem 'omniauth-twitter', '=0.0.14'
gem 'aws-ses', '=0.4.4', :require => 'aws/ses'

gem 'magic-localized_country_select', '=0.2.0', :require => 'localized_country_select'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'libv8', '=3.11.8.13', :platforms => :ruby
  gem 'therubyracer', '=0.11.3', :platforms => :ruby
  gem 'sass-rails',   '=3.2.6'
  gem 'coffee-rails', '=3.2.2'
  gem 'yui-compressor', '=0.9.6'
end

group :production, :travis do
  gem 'mysql2', '=0.3.11'
end

group :development do
  gem 'vagrant', '=1.0.6'
  gem 'capistrano-ext', '=1.2.1'
  gem 'travis-lint', '=1.6.0'
  gem 'foreman', '=0.61.0'
end

def linux_only(require_as)
  RUBY_PLATFORM.include?('linux') && require_as
end

group :test do
  gem 'mocha', '=0.13.2', :require => false
  gem 'rb-inotify', '=0.8.8', :require => linux_only('rb-inotify')
  gem 'shoulda-matchers', '=1.4.1', :require => false # 1.4.2 brings in a version of bourne that depends on older mocha
  gem 'factory_girl_rails', '=4.2.1'
end

group :development, :test do
  gem 'sqlite3', '=1.3.7'
  gem 'rspec-rails', '=2.13.0'
  gem 'guard-rspec', '=2.4.1'
  gem 'rb-fsevent', '=0.9.3'
  gem 'spork-rails', '=3.2.1'
  gem 'jasmine-jquery-rails', '=1.4.2'
  gem 'guard-jasmine', '=1.13.0'
  gem 'jasminerice', '=0.0.10'
end
