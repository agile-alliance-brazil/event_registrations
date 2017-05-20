class DropTableRegistrationPrice < ActiveRecord::Migration[4.2]
  def change
    add_money :registration_periods, :price, default: 0, null: false
    add_money :registration_quota, :price, default: 0, null: false

    drop_table :registration_prices do |t|
      t.references :registration_type
      t.references :registration_period

      t.decimal :value

      t.timestamps
    end
  end
end
