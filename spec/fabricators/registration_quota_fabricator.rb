# frozen_string_literal: true

Fabricator :registration_quota do
  event
  order { (1..100).to_a.sample }
  quota { 25 }
  closed { false }
  price { 40 }
end
