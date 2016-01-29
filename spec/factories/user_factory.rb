FactoryGirl.define do
  factory :user do
    first_name 'User'
    sequence(:last_name) { |n| "Name#{n}" }
    email do |a|
      username = "#{a.first_name} #{a.last_name}".parameterize
      "#{username}@example.com"
    end

    phone '(11) 3322-1234'
    country 'BR'
    state 'SP'
    city 'São Paulo'
    organization 'ThoughtWorks'
    badge_name { |e| "The Great #{e.first_name}" }
    cpf '111.444.777-35'
    gender 'M'
    twitter_user { |e| e.last_name.parameterize.to_s }
    address 'Rua dos Bobos, 0'
    neighbourhood 'Vila Perdida'
    zipcode '12345000'
  end

  factory :admin, parent: :user do
    roles [:admin]
  end
  factory :organizer, parent: :user do
    roles [:organizer]
  end
end
