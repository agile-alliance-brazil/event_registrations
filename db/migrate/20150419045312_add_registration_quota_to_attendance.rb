class AddRegistrationQuotaToAttendance < ActiveRecord::Migration[4.2]
  def change
    add_reference :attendances, :registration_quota, index: true
  end
end
