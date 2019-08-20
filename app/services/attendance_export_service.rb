# frozen_string_literal: true

class AttendanceExportService
  def self.to_csv(attendances_list)
    CSV.generate do |csv|
      csv << %i[id status registration_date first_name last_name organization email payment_type group_name city state value experience_in_agility education_level job_role]
      attendances_list.each do |attendance|
        csv << [attendance.id,
                I18n.t("activerecord.attributes.attendance.enums.status.#{attendance.status}", count: 1),
                attendance.registration_date,
                attendance.first_name,
                attendance.last_name,
                attendance.organization,
                attendance.email,
                attendance.payment_type,
                attendance.group_name,
                attendance.city,
                attendance.state,
                attendance.registration_value,
                attendance.experience_in_agility,
                attendance.education_level,
                attendance.organization_size,
                attendance.job_role]
      end
    end
  end
end
