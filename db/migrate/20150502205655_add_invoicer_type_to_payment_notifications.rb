# frozen_string_literal: true

class AddInvoicerTypeToPaymentNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column(:payment_notifications, :invoicer_type, :string) unless column_exists?(:payment_notifications, :invoicer_type)
  end
end
