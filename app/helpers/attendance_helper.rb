module AttendanceHelper
  def attendance_price(attendance, registration_type)
    attendance.registration_fee(registration_type)
  end

  def attendance_prices(attendance)
    attendance.event.registration_types.map do |registration_type|
      {registration_type.id => number_to_currency(attendance_price(attendance, registration_type), :locale => :pt)}
    end.inject({}, :merge)
  end

  def price_table_link(event, locale)
    event.price_table_link.gsub(%r(:locale(/?)), "#{locale}\\1")
  end

  def convert_registration_types_to_radio(attendance, registration_types)
    registration_types.map do |rt|
      price = number_to_currency(attendance_price(attendance, rt), locale: :pt)
      ["#{t(rt.title)} - #{price}", rt.id]
    end
  end
end