# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  first_name            :string(255)
#  last_name             :string(255)
#  email                 :string(255)
#  organization          :string(255)
#  phone                 :string(255)
#  country               :string(255)
#  state                 :string(255)
#  city                  :string(255)
#  badge_name            :string(255)
#  cpf                   :string(255)
#  gender                :string(255)
#  twitter_user          :string(255)
#  address               :string(255)
#  neighbourhood         :string(255)
#  zipcode               :string(255)
#  roles_mask            :integer
#  default_locale        :string(255)      default("pt")
#  created_at            :datetime
#  updated_at            :datetime
#  registration_group_id :integer
#
# Indexes
#
#  fk_rails_ebe9fba698  (registration_group_id)
#

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
    twitter_user { |e| "#{e.last_name.parameterize}" }
    address 'Rua dos Bobos, 0'
    neighbourhood 'Vila Perdida'
    zipcode '12345000'
  end

  factory :admin, parent: :user do
    roles [:admin]
  end
end
