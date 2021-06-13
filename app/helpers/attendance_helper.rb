# frozen_string_literal: true

module AttendanceHelper
  def attendance_price(attendance)
    attendance.registration_value
  end

  def price_table_link(event, locale)
    event.price_table_link.gsub(%r{:locale(/?)}, "#{locale}\\1")
  end

  def year_of_experience_options
    Attendance.years_of_experiences.map { |exp, key| [I18n.t("activerecord.attributes.attendance.enums.year_of_experience.#{exp}"), key] }
  end

  def experience_in_agility_options
    Attendance.experience_in_agilities.map { |exp, key| [I18n.t("activerecord.attributes.attendance.enums.experience_in_agility.#{exp}"), key] }
  end

  def organization_size_options
    Attendance.organization_sizes.map { |gender_options, key| [I18n.t("activerecord.attributes.attendance.enums.organization_size.#{gender_options}"), key] }
  end

  def job_role_options
    Attendance.job_roles.map { |job_role, key| [I18n.t("activerecord.attributes.attendance.enums.job_role.#{job_role}"), key] }.sort_by { |roles| roles[0] }
  end

  def payment_types_options
    Attendance.payment_types.map { |payment_type, _| [I18n.t("activerecord.attributes.attendance.enums.payment_types.#{payment_type}"), payment_type] }
  end
end
