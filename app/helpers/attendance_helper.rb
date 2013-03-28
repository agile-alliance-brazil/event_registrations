module AttendanceHelper
  def attendance_price(attendance, registration_type)
    old_type = attendance.registration_type
    attendance.registration_type = registration_type
    value = attendance.registration_fee
    attendance.registration_type = old_type
    value
  end
end