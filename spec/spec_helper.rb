# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/test/'
  add_filter '/spec/'
  add_filter 'app/controllers/sessions_controller.rb'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Views', 'app/views'
  add_group 'Library', 'lib/'

  minimum_coverage 100
end

require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'mocha/api'
require 'cancan/matchers'
require 'shoulda-matchers'
require 'rspec/collection_matchers'
require 'webmock/rspec'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

module Airbrake
  def self.notify(*_args)
    # do nothing.
  end
end

RSpec.configure do |config|
  Rails.application.eager_load!

  config.before(:suite) do
    # GC.disable
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation, except: %w[public.schema_migrations])
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
  # This was broken in rubocop 0.48.0 but already fixed on master in 2017-03-30
  # Remove the disables once rubocop > 0.48.0
  config.include(ControllerMacros, type: :controller)
  config.include(DisableAuthorization, type: :controller)

  config.include(TrimmerMacros)

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.render_views
end

def sign_in(user)
  controller.current_user = user
end
