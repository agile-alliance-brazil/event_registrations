class AddColumnQueueTimeToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :queue_time, :integer
  end
end
