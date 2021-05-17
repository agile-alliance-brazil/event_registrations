# frozen_string_literal: true

class DropTableInvoices < ActiveRecord::Migration[5.2]
  def up
    remove_column :attendances, :payment_type
    add_column :attendances, :payment_type, :integer

    execute 'DROP TABLE invoices CASCADE'

    remove_column :payment_notifications, :invoice_id
    remove_column :registration_groups, :invoice_id

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

    remove_foreign_key :attendances, :registration_quotas
    remove_foreign_key :attendances, :registration_periods
    remove_foreign_key :attendances, :users
    remove_foreign_key :attendances, :events
    remove_foreign_key :payment_notifications, :attendances

    remove_index :attendances, :event_id
    remove_index :attendances, :user_id

    remove_column :payment_notifications, :attendance_id

    add_column :payment_notifications, :invoice_id, :integer
    add_column :registration_groups, :invoice_id, :integer
  end
end
