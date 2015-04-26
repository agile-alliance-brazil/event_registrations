class AddRegistrationValueToAttendance < ActiveRecord::Migration
  def change
    add_column(:attendances, :registration_value, :decimal)
  end
end
