class AddRegistrationQuotaToAttendance < ActiveRecord::Migration
  def change
    add_reference :attendances, :registration_quota, index: true
  end
end
