# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    status :pending
    association :event
    association :user
    first_name { |a| a.user.first_name }
    last_name { |a| a.user.last_name }
    email { |a| a.user.email }
    phone { |a| a.user.phone }
    country { |a| a.user.country }
    state { |a| a.user.state }
    city { |a| a.user.city }
    organization { |a| a.user.organization }
    badge_name { |a| a.user.badge_name }
    cpf { |a| a.user.cpf }
    gender { |a| a.user.gender }
    registration_value 400.00
    organization_size { ['1 - 10', '11 - 30', '31 - 100', '100 - 500', '500 -'].sample }
    experience_in_agility { ['0 - 2', '3 - 7', '7 -'].sample }
    years_of_experience { ['0 - 5', '6 - 10', '11 - 20', '21 - 30', '31 -'].sample }

    registration_date { Time.zone.now }
    due_date { Time.zone.now + (event.days_to_charge * 2).days }
  end
end
