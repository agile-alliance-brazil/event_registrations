class DropTableRegistrationPrice < ActiveRecord::Migration
  def change

    add_money :registration_periods, :price, default: 0, null: false
    add_money :registration_quota, :price, default: 0, null: false

    RegistrationPrice.all.each do |price|
      period = RegistrationPeriod.where(id: price.registration_period_id).first
      period.update(price_cents: (price.value * 100)) if period.present?

      quota = RegistrationQuota.where(id: price.registration_quota_id).first
      quota.update(price_cents: (price.value * 100)) if quota.present?
    end

    drop_table :registration_prices do |t|
      t.references :registration_type
      t.references :registration_period

      t.decimal :value

      t.timestamps
    end
  end
end
