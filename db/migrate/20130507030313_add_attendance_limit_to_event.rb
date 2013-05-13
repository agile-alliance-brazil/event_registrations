class AddAttendanceLimitToEvent < ActiveRecord::Migration
  def change
    add_column :events, :attendance_limit, :integer
  end
end
