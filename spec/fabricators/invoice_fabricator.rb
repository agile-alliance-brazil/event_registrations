# frozen_string_literal: true

Fabricator :invoice do
  attendance
  invoice_date { Time.zone.now }
  status { :paid }
  transaction_id { '9JU83038HS278211W' }
end
