class AddRegistrationPeriodIdToAttendance < ActiveRecord::Migration[4.2]
  def change
    add_column(:attendances, :registration_period_id, :integer)
  end
end
