class AddRegistrationPeriodIdToAttendance < ActiveRecord::Migration
  def change
    add_column(:attendances, :registration_period_id, :integer)
  end
end
