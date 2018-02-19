FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "Agile Brazil #{2000 + n}" }
    price_table_link 'http://localhost:9292/link'
    full_price 850.00
    start_date { 1.month.from_now }
    end_date { 2.months.from_now }
    main_email_contact 'bla@xpto.com'
    attendance_limit 1000
    days_to_charge 2
  end
end
