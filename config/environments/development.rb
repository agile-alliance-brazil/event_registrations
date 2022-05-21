# frozen_string_literal: true

Current::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  host = 'http://127.0.0.1'
  config.action_mailer.default_url_options = { host: host, port: 3000 }
  config.action_mailer.asset_host = host
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.show_previews = true
  config.action_mailer.delivery_method = :smtp

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.logger = Logger.new(STDOUT)
  config.log_level = :INFO


  # Loading classes policy. true to load at start. false to load as needed
  config.eager_load = false

  config.force_ssl = false

  config.hosts << 'f0cc-161-22-56-164.sa.ngrok.io'
end
