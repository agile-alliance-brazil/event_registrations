class DropTableInvoiceAttendances < ActiveRecord::Migration
  def change
    drop_table :invoice_attendances do |t|
      t.belongs_to :invoice
      t.belongs_to :attendance

      t.timestamps
    end

    change_table :invoices do |t|
      t.references :invoiceable, polymorphic: true, index: true
    end

    remove_column :payment_notifications, :invoicer_id, :integer
    remove_column :payment_notifications, :invoicer_type, :string

    add_column :payment_notifications, :invoice_id, :integer
    add_foreign_key :payment_notifications, :invoices, column: :invoice_id, index: true
  end
end
