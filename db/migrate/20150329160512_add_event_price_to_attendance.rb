class AddEventPriceToAttendance < ActiveRecord::Migration[4.2]
  def change
    add_column :attendances, :event_price, :decimal
  end
end
