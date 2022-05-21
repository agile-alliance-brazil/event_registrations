# frozen_string_literal: true

class RenamePaymentNotificationToInvoice < ActiveRecord::Migration[7.0]
  def change
    add_index :payment_notifications, :id, name: 'payment_notifications_pkey'

    rename_table :payment_notifications, :invoices
  end
end
