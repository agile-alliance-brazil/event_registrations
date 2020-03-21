# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.4'
gem 'rails', '>= 6.0.2.2'

gem 'airbrake-ruby'

gem 'aws-ses', '~> 0.6.0', require: 'aws/ses'
gem 'brcpfcnpj', '>= 3.3.0'
gem 'carrierwave'
gem 'coffee-rails', '>= 5.0.0'
gem 'country_select'
gem 'devise', '>= 4.7.1'
gem 'erubis'
gem 'faker'
gem 'formtastic', '>= 3.1.5'
gem 'httparty'
gem 'jquery-rails', '>= 4.3.5'
gem 'mini_magick'
gem 'mysql2'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem 'pagseguro-oficial', git: 'https://github.com/jpaulomotta/ruby', branch: 'sandbox-find-by-notification-code' # due to the BigDecimal error on pagseguro bank ticket (boleto)
gem 'pry-rails' # should be in the development group, but we ran the console under the production environment in the cloud
gem 'rake'
gem 'sass'
gem 'sass-rails', '>= 6.0.0'
gem 'therubyracer', platforms: :ruby
gem 'will_paginate'
gem 'yui-compressor', require: 'yui/compressor'

group :development, :test do
  gem 'annotate'
  gem 'brakeman', require: false
  gem 'byebug', require: false
  gem 'database_cleaner'
  gem 'dotenv-rails', '>= 2.7.5', require: false
  gem 'factory_bot_rails', '>= 5.1.1'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'metric_fu'
  gem 'parser'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'rails-controller-testing', '>= 1.0.4'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails', '>= 3.9.0'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'sprockets-rails', '>= 3.2.1'
  gem 'sqlite3'
end

group :development do
  gem 'capistrano', '3.10.1', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-git-with-submodules', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  gem 'foreman'
  gem 'net-ssh'
  gem 'pry'
  gem 'travis-lint'
end

group :test do
  gem 'mocha', require: false
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'webmock'
end
