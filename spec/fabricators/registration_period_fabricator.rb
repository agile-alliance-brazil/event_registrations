# frozen_string_literal: true

Fabricator :registration_period do
  event
  title { 'registration_period.regular' }
  start_at { Time.zone.now }
  end_at { 1.day.from_now.end_of_day }
  price { 100 }
end
