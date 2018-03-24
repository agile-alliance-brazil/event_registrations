# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_notifications
#
#  id              :integer          not null, primary key
#  params          :text(65535)
#  status          :string(255)
#  transaction_id  :string(255)
#  payer_email     :string(255)
#  settle_amount   :decimal(10, )
#  settle_currency :string(255)
#  notes           :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#  invoice_id      :integer
#
# Indexes
#
#  fk_rails_92030b1506  (invoice_id)
#

FactoryBot.define do
  factory :payment_notification do
    params { { some: 'params', type: 'pagseguro' } }
    status 'Completed'
    transaction_id '9JU83038HS278211W'
    invoice
  end
end
