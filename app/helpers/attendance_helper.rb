module AttendanceHelper
  def attendance_price(attendance)
    attendance.registration_value
  end

  def price_table_link(event, locale)
    event.price_table_link.gsub(%r(:locale(/?)), "#{locale}\\1")
  end

  def convert_registration_types_to_radio(attendance, registration_types)
    registration_types.map do |rt|
      price = number_to_currency(attendance_price(attendance), locale: :pt)
      ["#{t(rt.title)} - #{price}", rt.id]
    end
  end
end