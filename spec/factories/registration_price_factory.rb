FactoryGirl.define do
  factory :registration_price do
    registration_type
    registration_period
    value 100.00
  end
end