class AddColumnLastStatusChangeToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :last_status_change_date, :datetime
  end
end
