# frozen_string_literal: true

FactoryBot.define do
  factory :payment_notification do
    attendance
    params { { some: 'params', type: 'pagseguro' } }
    status { 'Completed' }
    transaction_id { '9JU83038HS278211W' }
  end
end
