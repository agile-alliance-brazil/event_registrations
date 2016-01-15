# encoding: UTF-8
# == Schema Information
#
# Table name: authentications
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  provider      :string(255)
#  uid           :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  refresh_token :string(255)
#

class Authentication < ActiveRecord::Base
  PRODUCTION_PROVIDERS = %w(twitter facebook github submission_system).freeze
  OTHER_PROVIDERS = %w(twitter facebook github submission_system developer).freeze
  PROVIDERS = Rails.env.production? ? PRODUCTION_PROVIDERS : OTHER_PROVIDERS

  belongs_to :user

  validates :provider, :uid, presence: true

  def token
    return nil unless provider == 'submission_system' && refresh_token.present?

    client = OAuth2::Client.new(
      APP_CONFIG[:submission_system][:key],
      APP_CONFIG[:submission_system][:secret],
      site: APP_CONFIG[:submission_system][:url],
      parse_json: true
    )
    token = OAuth2::AccessToken.new(
      client,
      nil,
      refresh_token: refresh_token
    )
    new_token = token.refresh!
    update_attribute(:refresh_token, new_token.refresh_token)
    new_token
  end
end
