OmniAuth.config.logger = Rails.logger

raise "Twitter key/secret is not configured in config/config.yml file not found. Please check config/config.example for a sample" unless AppConfig[:twitter]
raise "Facebook key/secret is not configured in config/config.yml file not found. Please check config/config.example for a sample" unless AppConfig[:facebook]

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer unless Rails.env.production?
  # provider :github, AppConfig[:github][:key], AppConfig[:github][:secret]
  provider :twitter, AppConfig[:twitter][:key], AppConfig[:twitter][:secret]
  provider :facebook, AppConfig[:facebook][:key], AppConfig[:facebook][:secret]
  # require 'openid/store/filesystem'
  # provider :openid, :store => OpenID::Store::Filesystem.new(File.join(Rails.root, '/tmp'))
end
