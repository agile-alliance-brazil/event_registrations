# == Schema Information
#
# Table name: registration_quota
#
#  id                    :integer          not null, primary key
#  quota                 :integer
#  created_at            :datetime
#  updated_at            :datetime
#  event_id              :integer
#  registration_price_id :integer
#  order                 :integer
#  closed                :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :registration_quota do
    event
    registration_price
    quota 25
    closed false
  end
end
