class AddDaysToChargeToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :days_to_charge, :integer, default: 7
  end
end
