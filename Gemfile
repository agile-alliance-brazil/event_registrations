# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.4'
gem 'rails'

gem 'airbrake-ruby'

gem 'aws-ses', '~> 0.6.0', require: 'aws/ses'
gem 'brcpfcnpj'
gem 'carrierwave'
gem 'coffee-rails'
gem 'country_select'
gem 'devise'
gem 'erubis'
gem 'faker'
gem 'formtastic'
gem 'httparty'
gem 'jquery-rails'
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
gem 'sass-rails'
gem 'therubyracer', platforms: :ruby
gem 'will_paginate'
gem 'yui-compressor', require: 'yui/compressor'

group :development, :test do
  gem 'annotate'
  gem 'brakeman', require: false
  gem 'byebug', require: false
  gem 'database_cleaner'
  gem 'dotenv-rails', require: false
  gem 'factory_bot_rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'metric_fu', '>= 4.12.0'
  gem 'parser'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'sprockets-rails'
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
  gem 'travis-lint', '>= 2.0.0'
end

group :test do
  gem 'mocha', require: false
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'webmock'
end
