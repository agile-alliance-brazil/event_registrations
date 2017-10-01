# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
begin
  config_file = File.expand_path('../../config/config.yml', File.dirname(__FILE__))
  config = HashWithIndifferentAccess.new(YAML.load_file(config_file))
  Current::Application.config.secret_token = config[:secret_token]
  Current::Application.config.secret_key_base = config[:secret_key_base]
rescue StandardError
  raise 'config/config.yml file not found. Please check config/config.example for a sample'
end
