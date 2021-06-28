# frozen_string_literal: true

class AddOtherJobPositionToAttendance < ActiveRecord::Migration[6.0]
  def up
    add_column :attendances, :other_job_role, :string

    # president and clevel was grouped and the designer job role replaced the clevel index
    president = 5
    clevel = 6

    Attendance.where(job_role: clevel).update(job_role: president)
  end

  def down
    remove_column :attendances, :other_job_role, :string
  end
end
