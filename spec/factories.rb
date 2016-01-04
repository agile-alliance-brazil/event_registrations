# encoding: UTF-8

require 'faker'

FactoryGirl.define do
  factory :registration_period do
    association :event
    title 'registration_period.regular'
    start_at Time.zone.now
    end_at 1.day.from_now.end_of_day
    price 100
  end

  factory :attendance do
    association :event
    association :user
    first_name { |a| a.user.first_name }
    last_name { |a| a.user.last_name }
    email { |a| a.user.email }
    email_confirmation { |a| a.user.email }
    phone { |a| a.user.phone }
    country { |a| a.user.country }
    state { |a| a.user.state }
    city { |a| a.user.city }
    organization { |a| a.user.organization }
    badge_name { |a| a.user.badge_name }
    cpf { |a| a.user.cpf }
    gender { |a| a.user.gender }
    twitter_user { |a| a.user.twitter_user }
    address { |a| a.user.address }
    neighbourhood { |a| a.user.neighbourhood }
    zipcode { |a| a.user.zipcode }
    registration_value 400.00

    registration_date { Time.zone.now }
  end

  factory :authentication do
    user
    uid { |a| a.user.id }
    provider 'twitter'
  end

  factory :registration_group do
    name Faker::Company.name
    event
    minimum_size 13
    discount 15
  end
end
