# encoding: UTF-8
RegistrationPeriod.seed do |period|
  period.id = 1
  period.event_id = 1
  period.title = 'registration_period.super_early_bird'
  period.start_at = Time.zone.local(2013, 2, 1)
  period.end_at = Time.zone.local(2013, 3, 26).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 2
  period.event_id = 1
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2013, 3, 27)
  period.end_at = Time.zone.local(2013, 4, 15).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 3
  period.event_id = 1
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2013, 4, 16)
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

RegistrationPeriod.seed do |period|
  period.id = 6
  period.event_id = 2
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2013, 4, 14)
  period.end_at = Time.zone.local(2013, 4, 22).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 7
  period.event_id = 2
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2013, 4, 23)
  period.end_at = Time.zone.local(2013, 5, 11).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 8
  period.event_id = 2
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2013, 5, 12)
  period.end_at = Time.zone.local(2013, 5, 14).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 9
  period.event_id = 3
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2013, 5, 6)
  period.end_at = Time.zone.local(2013, 5, 20).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 10
  period.event_id = 3
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2013, 5, 21)
  period.end_at = Time.zone.local(2013, 6, 6).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 11
  period.event_id = 3
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2013, 6, 7)
  period.end_at = Time.zone.local(2013, 6, 22).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 12
  period.event_id = 4
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2013, 5, 6)
  period.end_at = Time.zone.local(2013, 5, 20).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 13
  period.event_id = 4
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2013, 5, 21)
  period.end_at = Time.zone.local(2013, 6, 6).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 14
  period.event_id = 4
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2013, 6, 7)
  period.end_at = Time.zone.local(2013, 6, 22).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 15
  period.event_id = 5
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2013, 5, 6)
  period.end_at = Time.zone.local(2013, 5, 20).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 16
  period.event_id = 5
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2013, 5, 21)
  period.end_at = Time.zone.local(2013, 6, 6).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 17
  period.event_id = 5
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2013, 6, 7)
  period.end_at = Time.zone.local(2013, 6, 22).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 18
  period.event_id = 6
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2013, 5, 6)
  period.end_at = Time.zone.local(2013, 5, 20).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 19
  period.event_id = 6
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2013, 5, 21)
  period.end_at = Time.zone.local(2013, 6, 6).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 20
  period.event_id = 6
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2013, 6, 7)
  period.end_at = Time.zone.local(2013, 6, 22).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 21
  period.event_id = 7
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2013, 5, 6)
  period.end_at = Time.zone.local(2013, 5, 20).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 22
  period.event_id = 7
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2013, 5, 21)
  period.end_at = Time.zone.local(2013, 6, 6).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 23
  period.event_id = 7
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2013, 6, 7)
  period.end_at = Time.zone.local(2013, 6, 22).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 24
  period.event_id = 8
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2013, 5, 6)
  period.end_at = Time.zone.local(2013, 5, 20).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 25
  period.event_id = 8
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2013, 5, 21)
  period.end_at = Time.zone.local(2013, 6, 6).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 26
  period.event_id = 8
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2013, 6, 7)
  period.end_at = Time.zone.local(2013, 6, 22).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 27
  period.event_id = 9
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2013, 5, 6)
  period.end_at = Time.zone.local(2013, 5, 20).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 28
  period.event_id = 9
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2013, 5, 21)
  period.end_at = Time.zone.local(2013, 6, 6).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 29
  period.event_id = 9
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2013, 6, 7)
  period.end_at = Time.zone.local(2013, 6, 22).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 30
  period.event_id = 10
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2013, 5, 6)
  period.end_at = Time.zone.local(2013, 5, 20).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 31
  period.event_id = 10
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2013, 5, 21)
  period.end_at = Time.zone.local(2013, 6, 6).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 32
  period.event_id = 10
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2013, 6, 7)
  period.end_at = Time.zone.local(2013, 6, 22).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 33
  period.event_id = 11
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2013, 5, 6)
  period.end_at = Time.zone.local(2013, 5, 20).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 34
  period.event_id = 11
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2013, 5, 21)
  period.end_at = Time.zone.local(2013, 6, 6).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 35
  period.event_id = 11
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2013, 6, 7)
  period.end_at = Time.zone.local(2013, 6, 22).end_of_day
end
