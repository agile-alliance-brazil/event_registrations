# frozen_string_literal: true

Fabricator :registration_group do
  event
  name { Faker::Company.name }
  minimum_size { 13 }
  discount { 15 }
end
