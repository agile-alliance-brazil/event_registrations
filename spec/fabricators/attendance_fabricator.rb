# frozen_string_literal: true

Fabricator :attendance do
  event
  user

  registered_by_user { Fabricate :user }

  status { %i[pending accepted paid confirmed].sample }

  country { 'BR' }
  state { 'SP' }
  city { 'São Paulo' }
  organization { 'ThoughtWorks' }
  badge_name { Faker::Company.name.gsub(/\W/, '') }
  registration_value { 400.00 }
  organization_size { Attendance.organization_sizes.keys.sample }
  experience_in_agility { Attendance.experience_in_agilities.keys.sample }
  years_of_experience { Attendance.years_of_experiences.keys.sample }

  registration_date { Time.zone.now }
  due_date { 2.months.from_now }
end
