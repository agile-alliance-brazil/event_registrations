FactoryGirl.define do
  factory :invoice do
    user
    status Invoice::PENDING
    amount 1.00
    payment_type Invoice::GATEWAY
  end

  factory :invoice_group, class: Invoice do
    registration_group
    status Invoice::PENDING
  end
end
