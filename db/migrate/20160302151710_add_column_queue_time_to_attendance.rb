class AddColumnQueueTimeToAttendance < ActiveRecord::Migration[4.2]
  def change
    add_column :attendances, :queue_time, :integer
  end
end
