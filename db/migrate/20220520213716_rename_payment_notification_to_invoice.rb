# frozen_string_literal: true

class RenamePaymentNotificationToInvoice < ActiveRecord::Migration[7.0]
  def change
    rename_table :payment_notifications, :invoices
  end
end
