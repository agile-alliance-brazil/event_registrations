FactoryBot.define do
  factory :registration_group do
    name { Faker::Company.name }
    event
    minimum_size 13
    discount 15
  end
end
