# frozen_string_literal: true

FactoryBot.define do
  factory :registration_quota do
    event
    sequence(:order)
    quota { 25 }
    closed { false }
    price { 40 }
  end
end
