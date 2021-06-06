# frozen_string_literal: true

Fabricator :event do
  name { Faker::Company.name.gsub(/\W/, '') }
  price_table_link { 'http://localhost:9292/link' }
  country { Faker::Address.country }
  state { Faker::Address.state }
  city { Faker::Address.city }
  full_price { 850.00 }
  start_date { 1.month.from_now }
  end_date { 2.months.from_now }
  main_email_contact { 'bla@xpto.com' }
  attendance_limit { 1000 }
  days_to_charge { 2 }
  link { 'www.foo.com' }
end
