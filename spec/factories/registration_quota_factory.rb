# frozen_string_literal: true

# == Schema Information
#
# Table name: registration_quotas
#
#  id                    :integer          not null, primary key
#  quota                 :integer
#  created_at            :datetime
#  updated_at            :datetime
#  event_id              :integer
#  registration_price_id :integer
#  order                 :integer
#  closed                :boolean          default(FALSE)
#  price_cents           :integer          default(0), not null
#  price_currency        :string(255)      default("BRL"), not null
#

FactoryBot.define do
  factory :registration_quota do
    event
    sequence(:order)
    quota 25
    closed false
    price 40
  end
end
