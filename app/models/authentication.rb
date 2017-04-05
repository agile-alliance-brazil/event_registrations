# encoding: UTF-8

# == Schema Information
#
# Table name: authentications
#
#  created_at    :datetime
#  id            :integer          not null, primary key
#  provider      :string
#  refresh_token :string
#  uid           :string
#  updated_at    :datetime
#  user_id       :integer
#

class Authentication < ActiveRecord::Base
  PRODUCTION_PROVIDERS = %w[twitter facebook github].freeze
  OTHER_PROVIDERS = %w[twitter facebook github developer].freeze
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
    self.refresh_token = new_token.refresh_token
    save!
    new_token
  end
end
