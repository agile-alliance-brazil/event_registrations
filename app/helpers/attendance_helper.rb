# frozen_string_literal: true

module AttendanceHelper
  def attendance_price(attendance)
    attendance.registration_value
  end

  def price_table_link(event, locale)
    event.price_table_link.gsub(%r{:locale(/?)}, "#{locale}\\1")
  end

  def education_level_options
    [
      [t('activerecord.attributes.attendance.enums.education_level.primary'), 'Primary education'],
      [t('activerecord.attributes.attendance.enums.education_level.secondary'), 'Secondary education'],
      [t('activerecord.attributes.attendance.enums.education_level.tec_secondary'), 'Post-secondary non-tertiary education'],
      [t('activerecord.attributes.attendance.enums.education_level.tec_terciary'), 'Short-cycle tertiary education'],
      [t('activerecord.attributes.attendance.enums.education_level.bachelor'), 'Bachelor or equivalent'],
      [t('activerecord.attributes.attendance.enums.education_level.master'), 'Master or equivalent'],
      [t('activerecord.attributes.attendance.enums.education_level.doctoral'), 'Doctoral or equivalent']
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
    Attendance.job_roles.map { |job_role| [t("activerecord.attributes.attendance.enums.job_role.#{job_role[0]}"), job_role[0]] }.sort_by { |roles| roles[0] }
  end

  def payment_types_options
    Attendance.payment_types.map { |payment_type, _| [I18n.t("activerecord.attributes.attendance.enums.payment_types.#{payment_type}"), payment_type] }
  end
end
