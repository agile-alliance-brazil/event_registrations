# frozen_string_literal: true

Fabricator :payment_notification do
  attendance
  params { { some: 'params', type: 'pagseguro' } }
  status { 'Completed' }
  transaction_id { '9JU83038HS278211W' }
end
