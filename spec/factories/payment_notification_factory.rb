FactoryGirl.define do
  factory :payment_notification do
    params { { some: 'params', type: 'pagseguro' } }
    status 'Completed'
    transaction_id '9JU83038HS278211W'
    invoice
  end
end