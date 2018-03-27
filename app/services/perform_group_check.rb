# frozen_string_literal: true

class PerformGroupCheck
  def self.run(attendance_param, token)
    attendance = attendance_param
    event = attendance.event
    group = event.registration_groups.find_by(token: token)

    if group.present?
      attendance.update(registration_group: group)
    elsif event.agile_alliance_discount_group? && AgileAllianceService.check_member(attendance.email)
      attendance.update(registration_group: event.agile_alliance_discount_group)
      attendance.accept
    end
    attendance
  end
end
