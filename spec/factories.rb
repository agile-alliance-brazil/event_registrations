# encoding: UTF-8

FactoryGirl.define do
  factory :event do
    sequence(:name) {|n| "Agile Brazil #{2000+n}"}
  end

  factory :attendee do
    association :event
    registration_type { RegistrationType.find_by_title('registration_type.individual') }
    
    first_name "Attendee"
    sequence(:last_name) {|n| "Name#{n}"}
    email { |e| "#{e.last_name.parameterize}@example.com" }
    email_confirmation { |e| "#{e.last_name.parameterize}@example.com" }
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

  factory :course do
    association :event
    name "Course"
    full_name "That big course of ours"
    combine false
  end

  factory :course_attendance do
    association :course
    association :attendee
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
    association :invoicer, :factory => :attendee
  end

  factory :user do
    
  end
end