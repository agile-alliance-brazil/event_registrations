# encoding: UTF-8
class Authentication < ActiveRecord::Base
  PROVIDERS = %w(twitter facebook github submission_system)
  PROVIDERS << 'developer' unless Rails.env.production?

  belongs_to :user

  validates_presence_of :provider
  validates_presence_of :uid

  def token
    return nil unless provider == 'submission_system' && refresh_token.present?

    client = OAuth2::Client.new(
      APP_CONFIG[:submission_system][:key],
      APP_CONFIG[:submission_system][:secret],
      :site => APP_CONFIG[:submission_system][:url],
      :parse_json => true
    )
    token = OAuth2::AccessToken.new(
      client,
      nil,
      :refresh_token => refresh_token
    )
    new_token = token.refresh!
    self.update_attribute(:refresh_token, new_token.refresh_token)
    new_token
  end
end
