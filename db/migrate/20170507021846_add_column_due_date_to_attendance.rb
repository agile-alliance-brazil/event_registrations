# frozen_string_literal: true

class AddColumnDueDateToAttendance < ActiveRecord::Migration[5.0]
  def change
    add_column :attendances, :due_date, :datetime
  end
end
