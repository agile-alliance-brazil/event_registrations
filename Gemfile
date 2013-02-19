source 'http://rubygems.org'

gem 'rails', '=3.2.12'
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

gem 'magic-localized_country_select', '=0.2.0', :require => 'localized_country_select'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'therubyracer', '0.11.3'
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

group :development, :test do
  gem 'sqlite3', '=1.3.7'
  gem 'mocha', '=0.13.2', :require => false
  gem 'rspec-rails', '=2.12.2'
  gem 'guard-rspec', '=2.3.3'
  gem 'rb-inotify', '=0.8.8', :require => linux_only('rb-inotify')
  gem 'shoulda-matchers', '=1.4.1' # 1.4.2 brings in a version of bourne that depends on older mocha
  gem 'factory_girl_rails', '=4.1.0'
  gem 'spork-rails', '=3.2.1'
  gem 'jasminerice', '=0.0.10'
  gem 'jasmine-jquery-rails', '=1.4.2'
  gem 'guard-jasmine', '=1.12.2'
end
