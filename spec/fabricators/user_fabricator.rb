# frozen_string_literal: true

Fabricator :user do
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name.gsub(/\W/, '') }
  email { Faker::Internet.email }
  password { 'abc123456' }
  password_confirmation { 'abc123456' }

  country { 'BR' }
  state { 'SP' }
  city { 'São Paulo' }
  gender { User.genders.keys.sample }
end
