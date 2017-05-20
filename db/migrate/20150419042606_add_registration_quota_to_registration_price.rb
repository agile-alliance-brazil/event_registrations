class AddRegistrationQuotaToRegistrationPrice < ActiveRecord::Migration[4.2]
  def change
    add_reference :registration_prices, :registration_quota, index: true
  end
end
