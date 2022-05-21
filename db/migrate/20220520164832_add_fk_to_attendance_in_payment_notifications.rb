# frozen_string_literal: true

class AddFkToAttendanceInPaymentNotifications < ActiveRecord::Migration[7.0]
  def up
    execute('UPDATE payment_notifications SET settle_amount = 0 WHERE settle_amount IS NULL')

    change_table :payment_notifications, bulk: true do |t|
      t.remove :settle_currency, type: :string
      t.remove :notes, type: :string
      t.remove :params, type: :string

      t.datetime :invoice_date
      t.integer :payment_type, index: true, null: false, default: 0

      t.remove :status
      t.integer :status, default: 1, index: true

      t.change_null :settle_amount, false
      t.change_null :transaction_id, false
    end

    execute('UPDATE payment_notifications p SET invoice_date = p.created_at')

    change_column_null :payment_notifications, :invoice_date, false

    remove_foreign_key :payment_notifications, :attendances, column: :attendance_id
    add_foreign_key :payment_notifications, :attendances, column: :attendance_id, on_delete: :cascade, on_update: :cascade
  end

  def down
    change_table :payment_notifications, bulk: true do |t|
      t.string :settle_currency
      t.string :notes
      t.string :params

      t.remove :payment_type
      t.change :status, :string
    end
  end
end
