class AddRegistrationQuotaToRegistrationPrice < ActiveRecord::Migration
  def change
    add_reference :registration_prices, :registration_quota, index: true
  end
end
