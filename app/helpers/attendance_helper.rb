module AttendanceHelper
  def attendance_price(attendance)
    attendance.registration_value
  end

  def price_table_link(event, locale)
    event.price_table_link.gsub(%r{:locale(/?)}, "#{locale}\\1")
  end

  def education_level_options
    [
      [t('attendance.enum.education_level.primary'), 'Primary education'],
      [t('attendance.enum.education_level.secondary'), 'Secondary education'],
      [t('attendance.enum.education_level.tec_secondary'), 'Post-secondary non-tertiary education'],
      [t('attendance.enum.education_level.tec_terciary'), 'Short-cycle tertiary education'],
      [t('attendance.enum.education_level.bachelor'), 'Bachelor or equivalent'],
      [t('attendance.enum.education_level.master'), 'Master or equivalent'],
      [t('attendance.enum.education_level.doctoral'), 'Doctoral or equivalent']
    ]
  end

  def year_of_experience_options
    ['0 - 5', '6 - 10', '11 - 20', '21 - 30', '31 -']
  end

  def experience_in_agility_options
    ['0 - 2', '3 - 7', '7 -']
  end

  def organization_size_options
    ['1 - 10', '11 - 30', '31 - 100', '100 - 500', '500 -']
  end

  def job_role_options
    Attendance.job_roles.map { |job_role| [t("attendances.new.form.job_role.#{job_role[0]}"), job_role[0]] }.sort_by { |roles| roles[0] }
  end

  def payment_types_options
    Invoice.payment_types.map { |payment_type, _| [I18n.t("activerecord.attributes.invoice.payment_types.#{payment_type}"), payment_type] }
  end
end
