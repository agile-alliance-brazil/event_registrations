# frozen_string_literal: true

class ChangeStatusFieldForAttendance < ActiveRecord::Migration[5.1]
  def up
    add_column :attendances, :status_string, :string
    execute('UPDATE attendances SET status_string = status;')
    execute('UPDATE attendances SET status = null;')

    change_column :attendances, :status, :integer

    Attendance.all.each { |attendance| attendance.update(status: Attendance.statuses[attendance.status_string]) if attendance.status_string.present? }

    remove_column :attendances, :status_string
  end

  def down
    add_column :attendances, :status_int, :integer
    execute('UPDATE attendances SET status_int = status;')
    execute('UPDATE attendances SET status = null;')

    change_column :attendances, :status, :string

    Attendance.all.each { |attendance| attendance.update(status: Attendance.statuses.key(attendance.status_int)) if attendance.status_int.present? }

    remove_column :attendances, :status_int
  end
end
