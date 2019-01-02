# frozen_string_literal: true

FactoryBot.define do
  factory :registration_group do
    association :event
    name { Faker::Company.name }
    minimum_size { 13 }
    discount { 15 }
  end
end
