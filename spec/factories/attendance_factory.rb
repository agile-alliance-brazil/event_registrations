FactoryGirl.define do
  factory :attendance do
    association :event
    association :user
    first_name { |a| a.user.first_name }
    last_name { |a| a.user.last_name }
    email { |a| a.user.email }
    email_confirmation { |a| a.user.email }
    phone { |a| a.user.phone }
    country { |a| a.user.country }
    state { |a| a.user.state }
    city { |a| a.user.city }
    organization { |a| a.user.organization }
    badge_name { |a| a.user.badge_name }
    cpf { |a| a.user.cpf }
    gender { |a| a.user.gender }
    twitter_user { |a| a.user.twitter_user }
    address { |a| a.user.address }
    neighbourhood { |a| a.user.neighbourhood }
    zipcode { |a| a.user.zipcode }
    registration_value 400.00

    registration_date { Time.zone.now }
  end
end
