# encoding: UTF-8

require 'faker'

FactoryGirl.define do
  factory :event do
    sequence(:name) {|n| "Agile Brazil #{2000 + n}"}
    price_table_link "http://localhost:9292/link"

    after(:build) do |event|
      event.registration_types << FactoryGirl.build(:registration_type, :event => event)
      event.registration_periods << FactoryGirl.build(:registration_period, :event => event)
      event
    end
  end

  factory :registration_type do
    association :event
    title 'registration_type.individual'
  end

  factory :registration_period do
    association :event
    title 'registration_period.regular'
    start_at Time.zone.now
    end_at((Time.zone.now + 1.day).end_of_day)
  end

  factory :attendance do
    association :event
    association :user
    first_name {|a| a.user.first_name }
    last_name {|a| a.user.last_name }
    email {|a| a.user.email }
    email_confirmation {|a| a.user.email }
    phone {|a| a.user.phone }
    country {|a| a.user.country }
    state {|a| a.user.state }
    city {|a| a.user.city }
    organization {|a| a.user.organization }
    badge_name {|a| a.user.badge_name }
    cpf {|a| a.user.cpf }
    gender {|a| a.user.gender }
    twitter_user {|a| a.user.twitter_user }
    address {|a| a.user.address }
    neighbourhood {|a| a.user.neighbourhood }
    zipcode {|a| a.user.zipcode }

    registration_type { |a| a.event.registration_types.find_by_title('registration_type.individual') }
    registration_date { Time.zone.now }
  end

  factory :payment_notification do
    params { {some: 'params', type: 'paypal'} }
    status "Completed"
    transaction_id "9JU83038HS278211W"
    association :invoicer, factory: :attendance
  end

  factory :user do
    first_name "User"
    sequence(:last_name) {|n| "Name#{n}"}
    email do |user|
      username = "#{user.first_name} #{user.last_name}".parameterize
      "#{username}@example.com"
    end

    phone "(11) 3322-1234"
    country "BR"
    state "SP"
    city "São Paulo"
    organization "ThoughtWorks"
    badge_name {|e| "The Great #{e.first_name}" }
    cpf "111.444.777-35"
    gender 'M'
    twitter_user {|e| "#{e.last_name.parameterize}"}
    address "Rua dos Bobos, 0"
    neighbourhood "Vila Perdida"
    zipcode "12345000"
  end

  factory :authentication do
    user
    uid { |a| a.user.id }
    provider "twitter"
  end

  factory :registration_group do
    name Faker::Company.name
    event
  end
end