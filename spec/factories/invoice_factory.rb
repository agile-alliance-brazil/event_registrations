FactoryGirl.define do
  factory :invoice do
    user
    status Invoice::PENDING
    amount 1.00
    payment_type { %w(gateway bank_deposit statement_agreement).sample }
  end

  factory :invoice_group, class: Invoice do
    invoiceable registration_group
    status Invoice::PENDING
  end
end
