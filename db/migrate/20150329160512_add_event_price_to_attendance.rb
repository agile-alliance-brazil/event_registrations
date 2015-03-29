class AddEventPriceToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :event_price, :decimal
  end
end
