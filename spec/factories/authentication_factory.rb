FactoryBot.define do
  factory :authentication do
    user
    uid { |a| a.user.id }
    provider 'twitter'
  end
end
