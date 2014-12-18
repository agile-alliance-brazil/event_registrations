source 'http://rubygems.org'
ruby '1.9.3'

def linux_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /linux/ ? require_as : false
end
# Mac OS X
def darwin_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /darwin/ ? require_as : false
end

gem 'rails', '=4.0.12'
gem 'inherited_resources', '=1.5.1'
gem 'seed-fu', '=2.3.3'
gem 'brhelper', '=3.3.0'
gem 'brcpfcnpj', '=3.3.0'
gem 'validates_existence', '=0.9.2'
gem 'state_machine', '=1.2.0'
gem 'haml', '=4.0.6'
gem 'formtastic', '=3.1.2'
gem 'airbrake', '=4.1.0'
gem 'localized_country_select', '=0.9.9'
gem 'cancan', '=1.6.10'
gem 'jquery-rails', '=3.1.2' # 4.0.1 requires rails 4.2.0.beta
gem 'rake'
gem 'will_paginate', '=3.0.7'
gem 'omniauth', '=1.2.2'
gem 'omniauth-twitter', '=1.1.0'
gem 'omniauth-facebook', '=2.0.0'
gem 'omniauth-github', '=1.1.2'
gem 'aws-ses', '=0.6.0', require: 'aws/ses'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'therubyracer', '=0.12.1', :platforms => :ruby
  gem 'sass-rails',   '=5.0.0'
  gem 'coffee-rails', '=4.1.0'
  gem 'yui-compressor', '=0.12.0', require: 'yui/compressor'
end

group :production, :travis do
  gem 'mysql2', '=0.3.17'
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
  gem 'guard-konacha', git: 'https://github.com/lbeder/guard-konacha.git'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'selenium-webdriver'
end

group :development do
  gem 'capistrano', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'travis-lint'
  gem 'foreman'
end

group :test do
  gem 'mocha', require: false
  gem 'shoulda-matchers', require: false
  gem 'factory_girl_rails'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
end
