class AddColumnDueDateToAttendance < ActiveRecord::Migration[5.0]
  def change
    add_column :attendances, :due_date, :datetime
  end
end
