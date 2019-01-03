# frozen_string_literal: true

class RemoveMoneyGem < ActiveRecord::Migration[5.2]
  def up
    add_column :registration_periods, :price, :decimal
    execute('UPDATE registration_periods period SET price = (period.price_cents) / 100')

    add_column :registration_quotas, :price, :decimal
    execute('UPDATE registration_quotas quota SET price = (quota.price_cents) / 100')

    change_column_null :registration_periods, :price, false
    change_column_null :registration_quotas, :price, false

    remove_column :registration_periods, :price_cents
    remove_column :registration_periods, :price_currency

    remove_column :registration_quotas, :price_cents
    remove_column :registration_quotas, :price_currency
  end

  def down
    add_column :registration_periods, :price_cents, :decimal
    add_column :registration_periods, :price_currency, :decimal
    execute("UPDATE registration_periods period SET price_cents = (period.price * 100), price_currency = 'BRL'")

    add_column :registration_quotas, :price, :decimal
    add_column :registration_quotas, :price_currency, :decimal
    execute("UPDATE registration_quotas quota SET price_cents = (quota.price * 100), price_currency = 'BRL'")

    remove_column :registration_periods, :price
    remove_column :registration_quotas, :price
  end
end
