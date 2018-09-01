# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name.gsub(/\W/, '') }
    email { Faker::Internet.email }
    password { 'abc123456' }
    password_confirmation { 'abc123456' }

    phone { '(11) 3322-1234' }
    country { 'BR' }
    state { 'SP' }
    city { 'São Paulo' }
    organization { 'ThoughtWorks' }
    badge_name { |e| "The Great #{e.first_name}" }
    cpf { '111.444.777-35' }
    gender { 'M' }
    twitter_user { |e| e.last_name.parameterize.to_s }
    address { 'Rua dos Bobos, 0' }
    neighbourhood { 'Vila Perdida' }
    zipcode { '12345000' }
  end

  factory :admin, parent: :user do
    role { :admin }
  end
  factory :organizer, parent: :user do
    role { :organizer }
  end
end
