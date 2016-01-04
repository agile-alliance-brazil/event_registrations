module AttendanceHelper
  def attendance_price(attendance)
    attendance.registration_value
  end

  def price_table_link(event, locale)
    event.price_table_link.gsub(%r{:locale(/?)}, "#{locale}\\1")
  end
end
