class AddAttendancesInvoices < ActiveRecord::Migration
  def change
    create_table :attendances_invoices do |t|
      t.belongs_to :attendance
      t.belongs_to :invoice

      t.timestamps
    end

    add_index :attendances_invoices, [:attendance_id, :invoice_id], :unique => true
  end
end
