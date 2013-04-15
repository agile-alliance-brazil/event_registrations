module AttendanceHelper
  def attendance_price(attendance, registration_type)
    old_type = attendance.registration_type
    attendance.registration_type = registration_type
    value = attendance.registration_fee
    attendance.registration_type = old_type
    value
  end

  def attendance_prices(attendance)
    attendance.event.registration_types.map do |registration_type|
      number_to_currency(attendance_price(attendance, registration_type), :locale => :pt)
    end
  end
end