# == Schema Information
#
# Table name: invoices
#
#  id                    :integer          not null, primary key
#  frete                 :integer
#  amount                :decimal(10, )
#  created_at            :datetime
#  updated_at            :datetime
#  user_id               :integer
#  registration_group_id :integer
#  status                :string(255)
#  payment_type          :string(255)
#

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
