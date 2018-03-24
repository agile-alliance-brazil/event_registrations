# frozen_string_literal: true

class AddInvoice < ActiveRecord::Migration[4.2]
  def change
    create_table :invoices do |t|
      t.integer :frete
      t.decimal :amount

      t.timestamps

      t.belongs_to :user
      t.belongs_to :registration_group
    end
  end
end
