class AddOrderToRegistrationQuota < ActiveRecord::Migration
  def change
    add_column(:registration_quota, :order, :integer)
  end
end
