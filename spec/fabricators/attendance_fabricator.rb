# frozen_string_literal: true

Fabricator :attendance do
  event
  user

  registered_by_user { Fabricate :user }

  status { %i[pending accepted paid confirmed].sample }
  email { Faker::Internet.email }
  first_name { Faker::Name.first_name.gsub(/\W/, '') }
  last_name { Faker::Name.last_name.gsub(/\W/, '') }

  phone { '(11) 3322-1234' }
  country { 'BR' }
  state { 'SP' }
  city { 'São Paulo' }
  organization { 'ThoughtWorks' }
  badge_name { Faker::Company.name.gsub(/\W/, '') }
  cpf { '111.444.777-35' }
  gender { 'M' }
  registration_value { 400.00 }
  organization_size { ['1 - 10', '11 - 30', '31 - 100', '100 - 500', '500 -'].sample }
  experience_in_agility { ['0 - 2', '3 - 7', '7 -'].sample }
  years_of_experience { ['0 - 5', '6 - 10', '11 - 20', '21 - 30', '31 -'].sample }

  registration_date { Time.zone.now }
  due_date { 2.months.from_now }
end
