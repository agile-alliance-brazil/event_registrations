# frozen_string_literal: true

class DropTableInvoiceAttendances < ActiveRecord::Migration[4.2]
  def change
    drop_table :invoice_attendances do |t|
      t.belongs_to :invoice
      t.belongs_to :attendance

      t.timestamps
    end

    add_reference(:invoices, :invoiceable, polymorphic: true, index: true)
    remove_column :payment_notifications, :invoicer_id, :integer
    remove_column :payment_notifications, :invoicer_type, :string

    add_column :payment_notifications, :invoice_id, :integer
    add_foreign_key :payment_notifications, :invoices, column: :invoice_id, index: true
  end
end
