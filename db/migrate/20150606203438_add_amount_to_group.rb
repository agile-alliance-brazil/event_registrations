class AddAmountToGroup < ActiveRecord::Migration
  def change
    add_column(:registration_groups, :amount, :decimal)
  end
end
