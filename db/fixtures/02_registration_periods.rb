# encoding: UTF-8
RegistrationPeriod.seed do |period|
  period.id = 1
  period.event_id = 1
  period.title = 'registration_period.super_early_bird'
  period.start_at = Time.zone.local(2013, 2, 1)
  period.end_at = Time.zone.local(2013, 3, 14).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 2
  period.event_id = 1
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2013, 3, 1)
  period.end_at = Time.zone.local(2013, 4, 1).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 3
  period.event_id = 1
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2013, 4, 1)
  period.end_at = Time.zone.local(2013, 5, 31).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 4
  period.event_id = 1
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2013, 6, 1)
  period.end_at = Time.zone.local(2013, 6, 16).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 5
  period.event_id = 1
  period.title = 'registration_period.last_minute'
  period.start_at = Time.zone.local(2013, 6, 17)
  period.end_at = Time.zone.local(2013, 6, 28).end_of_day
end
