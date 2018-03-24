# frozen_string_literal: true

class RemoveInvoicerTypeFromPaymentNotifications < ActiveRecord::Migration[4.2]
  def change
    remove_column :payment_notifications, :invoicer_type, :string
  end
end
