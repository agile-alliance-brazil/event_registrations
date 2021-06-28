# frozen_string_literal: true

module AttendanceHelper
  def attendance_price(attendance)
    attendance.registration_value
  end

  def year_of_experience_options(selected_value = :no_experience_informed)
    options_for_select(Attendance.years_of_experiences.map { |exp, _key| [I18n.t("activerecord.attributes.attendance.enums.years_of_experience.#{exp}"), exp] }, selected_value)
  end

  def experience_in_agility_options(selected_value = :no_agile_expirience_informed)
    options_for_select(Attendance.experience_in_agilities.map { |exp, _key| [I18n.t("activerecord.attributes.attendance.enums.experience_in_agility.#{exp}"), exp] }, selected_value)
  end

  def organization_size_options(selected_value = :no_org_size_informed)
    options_for_select(Attendance.organization_sizes.map { |gender_options, _key| [I18n.t("activerecord.attributes.attendance.enums.organization_size.#{gender_options}"), gender_options] }, selected_value)
  end

  def job_role_options(selected_value = :not_informed)
    options_for_select(Attendance.job_roles.map { |job_role, _key| [I18n.t("activerecord.attributes.attendance.enums.job_role.#{job_role}"), job_role] }.sort_by { |roles| roles[0] }, selected_value)
  end

  def payment_types_options(selected_value = :gateway)
    options_for_select(Attendance.payment_types.map { |payment_type, _key| [I18n.t("activerecord.attributes.attendance.enums.payment_types.#{payment_type}"), payment_type] }, selected_value)
  end

  def source_of_interest_options(selected_value = :no_source_informed)
    options_for_select(Attendance.source_of_interests.map { |interest, _key| [I18n.t("activerecord.attributes.attendance.enums.source_of_interest.#{interest}"), interest] }, selected_value)
  end
end
