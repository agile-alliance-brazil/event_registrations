# frozen_string_literal: true

Fabricator :event do
  name { Faker::Company.name.gsub(/\W/, '') }
  event_nickname { 'Agile Brazil' }
  country { 'BR' }
  state { Faker::Address.state }
  city { Faker::Address.city }
  full_price { 850.00 }
  start_date { 1.month.from_now }
  end_date { 2.months.from_now }
  main_email_contact { 'bla@xpto.com' }
  attendance_limit { 1000 }
  days_to_charge { 2 }
  link { 'www.foo.com' }
  event_remote_platform_mail { 'no-reply@foo.com' }
  event_remote_manual_link { 'http://the.manual.com' }
  event_schedule_link { 'http://event.schedule.link' }
end
