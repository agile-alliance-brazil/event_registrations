class AddDaysToChargeToEvent < ActiveRecord::Migration
  def change
    add_column :events, :days_to_charge, :integer, default: 7
  end
end
