# frozen_string_literal: true

class AddInvoiceAttendances < ActiveRecord::Migration[4.2]
  def change
    create_table :invoice_attendances do |t|
      t.belongs_to :invoice
      t.belongs_to :attendance

      t.timestamps
    end

    add_index :invoice_attendances, %i[invoice_id attendance_id], unique: true
  end
end
