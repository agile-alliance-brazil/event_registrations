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
#  invoiceable_id        :integer
#  invoiceable_type      :string(255)
#
# Indexes
#
#  index_invoices_on_invoiceable_type_and_invoiceable_id  (invoiceable_type,invoiceable_id)
#

FactoryGirl.define do
  factory :invoice do
    user
    status Invoice::PENDING
    amount 1.00
    payment_type Invoice::GATEWAY
  end

  factory :invoice_group, class: Invoice do
    invoiceable registration_group
    status Invoice::PENDING
  end
end
