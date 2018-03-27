# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.4.3'
gem 'rails', '~> 5.0', '>= 5.0.2'

gem 'airbrake', '~> 7.0'
gem 'autoprefixer-rails', '~> 8.0'

gem 'aws-ses', '~> 0.6.0', require: 'aws/ses'
gem 'bootstrap-sass', '~> 3.3'
gem 'brcpfcnpj', '~> 3.3.0'
gem 'cancancan', '~> 2.0'
gem 'coffee-rails', '~> 4.1'
gem 'erubis', '~> 2.7'
gem 'faker'
gem 'formtastic', '~> 3.1.3'
gem 'haml', '~> 5.0'
gem 'httparty'
gem 'jquery-rails'
gem 'localized_country_select'
gem 'money-rails'
gem 'mysql2', '< 0.5' # remove restriction when rails supports mysql2 0.5+
gem 'omniauth', '~>1.3'
gem 'omniauth-facebook', '~>4.0'
gem 'omniauth-github', '~>1.1'
gem 'omniauth-twitter', '~>1.2'
gem 'pagseguro-oficial', git: 'git@github.com:correamarques/ruby.git'
gem 'pry-rails' # should be in the development group, but we ran the console under the production environment in the cloud
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
  gem 'factory_bot_rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'metric_fu'
  gem 'parser'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop', require: false
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
  gem 'travis-lint'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'mocha', require: false
  gem 'shoulda-matchers', git: 'https://github.com/wuakitv/shoulda-matchers', ref: 'd576b2d'
  gem 'simplecov'
  gem 'timecop'
  gem 'webmock'
end
