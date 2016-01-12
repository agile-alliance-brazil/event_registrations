# == Schema Information
#
# Table name: registration_periods
#
#  id             :integer          not null, primary key
#  event_id       :integer
#  title          :string(255)
#  start_at       :datetime
#  end_at         :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  price_cents    :integer          default(0), not null
#  price_currency :string(255)      default("BRL"), not null
#

FactoryGirl.define do
  factory :registration_period do
    association :event
    title 'registration_period.regular'
    start_at Time.zone.now
    end_at 1.day.from_now.end_of_day
    price 100
  end
end
