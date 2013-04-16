module AttendanceHelper
  def attendance_price(attendance, registration_type)
    attendance.registration_fee(registration_type)
  end

  def attendance_prices(attendance)
    attendance.event.registration_types.map do |registration_type|
      number_to_currency(attendance_price(attendance, registration_type), :locale => :pt)
    end
  end
end