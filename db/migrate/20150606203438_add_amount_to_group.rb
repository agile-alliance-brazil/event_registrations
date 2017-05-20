class AddAmountToGroup < ActiveRecord::Migration[4.2]
  def change
    add_column(:registration_groups, :amount, :decimal)
  end
end
