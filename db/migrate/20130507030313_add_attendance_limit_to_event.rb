class AddAttendanceLimitToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :attendance_limit, :integer
  end
end
