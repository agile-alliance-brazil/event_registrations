OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer unless Rails.env.production?
  # provider :github, AppConfig[:github][:key], AppConfig[:github][:secret]
  provider :twitter, AppConfig[:twitter][:key], AppConfig[:twitter][:secret]
  # require 'openid/store/filesystem'
  # provider :openid, :store => OpenID::Store::Filesystem.new(File.join(Rails.root, '/tmp'))
end