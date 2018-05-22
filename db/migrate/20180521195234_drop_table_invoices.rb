# frozen_string_literal: true

class DropTableInvoices < ActiveRecord::Migration[5.2]
  def up
    execute 'SET FOREIGN_KEY_CHECKS=0;'

    remove_column :attendances, :payment_type
    add_column :attendances, :payment_type, :integer

    execute('UPDATE attendances INNER JOIN invoices ON invoices.user_id = attendances.user_id SET attendances.payment_type = invoices.payment_type;')
    execute('UPDATE attendances SET attendances.payment_type = 1 WHERE attendances.payment_type IS NULL;')

    drop_table :invoices
    remove_column :payment_notifications, :invoice_id
    remove_column :registration_groups, :invoice_id

    execute 'SET FOREIGN_KEY_CHECKS=1;'

    add_column :payment_notifications, :attendance_id, :integer
    add_foreign_key :payment_notifications, :attendances, column: :attendance_id
    add_index :payment_notifications, :attendance_id

    # Create FK to attendances and fix relations
    add_foreign_key :attendances, :events, column: :event_id
    add_index :attendances, :event_id
    change_column_null :attendances, :event_id, false

    add_foreign_key :attendances, :users, column: :user_id
    add_index :attendances, :user_id
    change_column_null :attendances, :user_id, false

    add_foreign_key :attendances, :registration_quotas, column: :registration_quota_id
    add_foreign_key :attendances, :registration_periods, column: :registration_period_id
  end

  def down
    create_table :invoices do |t|
      t.integer :frete
      t.integer :status
      t.decimal :amount
      t.string :payment_type

      t.timestamps

      t.integer :user_id
      t.integer :registration_group_id
    end

    remove_column :payment_notifications, :attendance_id

    add_column :payment_notifications, :invoice_id, :integer
    add_column :registration_groups, :invoice_id, :integer
  end
end
