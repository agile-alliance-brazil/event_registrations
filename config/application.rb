# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'rails/all'
require 'csv'

Bundler.require(:default, Rails.env) if defined?(Bundler)

# Needed for Guard::Konacha since it'll try to initialize
# with the same configs but won't invoke the Current::Application
I18n.available_locales = %w[en pt]

module Current
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    config.load_defaults 5.0

    config.active_support.default_message_encryptor_serializer = :hybrid

    config.active_record.schema_format = :sql
    config.active_record.legacy_connection_handling = false

    config.action_controller.default_protect_from_forgery = true

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = %w[pt en]
    config.i18n.default_locale = 'pt'
    config.time_zone = 'Brasilia'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += %w[password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    # config.assets.css_compressor = :yui
    # config.assets.js_compressor = :uglifier

    require 'sidekiq/web'
  end
end
