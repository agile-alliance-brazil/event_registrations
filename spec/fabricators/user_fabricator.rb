# frozen_string_literal: true

Fabricator :user do
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
  badge_name { Faker::Company.name.gsub(/\W/, '') }
  cpf { '111.444.777-35' }
  gender { 'M' }
  twitter_user { Faker::Company.name.gsub(/\W/, '') }
  address { 'Rua dos Bobos, 0' }
  neighbourhood { 'Vila Perdida' }
  zipcode { '12345000' }
end
