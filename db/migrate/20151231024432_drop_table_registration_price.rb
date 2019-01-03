# frozen_string_literal: true

class DropTableRegistrationPrice < ActiveRecord::Migration[4.2]
  def change
    add_column :registration_periods, :price_cents, :decimal
    add_column :registration_periods, :price_currency, :string

    add_column :registration_quota, :price_cents, :decimal
    add_column :registration_quota, :price_currency, :string

    drop_table :registration_prices do |t|
      t.references :registration_type
      t.references :registration_period

      t.decimal :value

      t.timestamps
    end
  end
end
