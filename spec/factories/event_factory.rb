# == Schema Information
#
# Table name: events
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  location_and_date :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  price_table_link  :string(255)
#  allow_voting      :boolean
#  attendance_limit  :integer
#  full_price        :decimal(10, )
#  start_date        :datetime
#  end_date          :datetime
#

FactoryGirl.define do
  factory :event do
    sequence(:name) { |n| "Agile Brazil #{2000 + n}" }
    price_table_link 'http://localhost:9292/link'
    full_price 850.00
    start_date 1.month.from_now
    end_date 2.months.from_now
  end
end
