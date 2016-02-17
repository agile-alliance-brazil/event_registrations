module AttendanceHelper
  def attendance_price(attendance)
    attendance.registration_value
  end

  def price_table_link(event, locale)
    event.price_table_link.gsub(%r{:locale(/?)}, "#{locale}\\1")
  end

  def education_level_options
    {
      :'Primary education' => 'Primary education',
      :'Lower secondary education' => 'Lower secondary education',
      :'Upper secondary education' => 'Upper secondary education',
      :'Post-secondary non-tertiary education' => 'Post-secondary non-tertiary education',
      :'Short-cycle tertiary education' => 'Short-cycle tertiary education',
      :'Bachelor or equivalent' => 'Bachelor or equivalent',
      :'Master or equivalent' => 'Master or equivalent',
      :'Doctoral or equivalent' => 'Doctoral or equivalent'
    }
  end

  def year_of_experience_options
    {
      :'0 - 5' => '0 - 5',
      :'6 - 10' => '6 - 10',
      :'11 - 20' => '11 - 20',
      :'21 - 30' => '21 - 30',
      :'31 -' => '31 -'
    }
  end

  def organization_size_options
    {
      :'1 - 10' => '1 - 10',
      :'11 - 30' => '11 - 30',
      :'31 - 100' => '31 - 100',
      :'100 - 500' => '100 - 500',
      :'500 -' => '500 -'
    }
  end
end
