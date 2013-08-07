# encoding: UTF-8
# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
begin
  config = YAML.load_file("#{Rails.root}/config/config.yml")
  Current::Application.config.secret_token = config[:secret_token]
  Current::Application.config.secret_token_base = config[:secret_token_base]
rescue
  raise "config/config.yml file not found. Please check config/config.example for a sample"
end
