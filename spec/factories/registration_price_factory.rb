# == Schema Information
#
# Table name: registration_prices
#
#  id                     :integer          not null, primary key
#  registration_type_id   :integer
#  registration_period_id :integer
#  value                  :decimal(, )
#  created_at             :datetime
#  updated_at             :datetime
#  registration_quota_id  :integer
#

FactoryGirl.define do
  factory :registration_price do
    registration_type
    registration_period
    value 100.00
  end
end
