# encoding: UTF-8
RegistrationPeriod.seed do |period|
  period.id = 1
  period.event_id = 1
  period.title = 'registration_period.pre_register'
  period.start_at = Time.zone.local(2011, 3, 1)
  period.end_at = Time.zone.local(2011, 3, 14).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 2
  period.event_id = 1
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2011, 3, 1)
  period.end_at = Time.zone.local(2011, 4, 30).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 3
  period.event_id = 1
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2011, 5, 1)
  period.end_at = Time.zone.local(2011, 6, 30).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 4
  period.event_id = 1
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2011, 7, 1)
  period.end_at = Time.zone.local(2011, 8, 1).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 5
  period.event_id = 2
  period.title = 'registration_period.pre_register'
  period.start_at = Time.zone.local(2012, 12, 25)
  period.end_at = Time.zone.local(2013, 2, 28).end_of_day
end