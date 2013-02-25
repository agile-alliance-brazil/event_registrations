# encoding: UTF-8

FactoryGirl.define do
  factory :event do
    sequence(:year) {|n| 2000 + n }
    name {|e| "Agile Brazil #{e.year}"}
  end

  factory :attendance do
    association :event
    association :user

    registration_type { RegistrationType.find_by_title('registration_type.individual') }
    registration_date { RegistrationPeriod.find_by_title('registration_period.regular').start_at }
  end

  factory :registration_group do
    name "Big Corp"
    contact_name "Contact Name"
    contact_email { |e| "contact@#{e.name.parameterize}.com" }
    contact_email_confirmation { |e| "contact@#{e.name.parameterize}.com" }
    phone "(11) 3322-1234"
    fax "(11) 4422-1234"
    country "BR"
    state "SP"
    city "São Paulo"
    cnpj "69.103.604/0001-60"
    state_inscription "110.042.490.114"
    municipal_inscription "9999999"
    address "Rua dos Bobos, 0"
    neighbourhood "Vila Perdida"
    zipcode "12345000"
    total_attendees 5
  end

  factory :payment_notification do
    params { {:some => 'params'} }
    status "Completed"
    transaction_id "9JU83038HS278211W"
    association :invoicer, :factory => :attendance
  end

  factory :user do
    first_name "User"
    sequence(:last_name) {|n| "Name#{n}"}
    email { |a| username = "#{a.first_name} #{a.last_name}".parameterize; "#{username}@example.com" }

    phone "(11) 3322-1234"
    country "BR"
    state "SP"
    city "São Paulo"
    organization "ThoughtWorks"
    badge_name {|e| "The Great #{e.first_name}" }
    cpf "111.444.777-35"
    gender 'M'
    twitter_user {|e| "#{e.last_name.parameterize}"}
    address "Rua dos Bobos, 0"
    neighbourhood "Vila Perdida"
    zipcode "12345000"
  end
end