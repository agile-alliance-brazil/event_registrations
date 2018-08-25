# frozen_string_literal: true

class PerformGroupCheck
  include Singleton

  def run(attendance_param, token)
    attendance = attendance_param
    event = attendance.event
    group = event.registration_groups.find_by(token: token)

    if group.present?
      attendance.update(registration_group: group)
      attendance.accepted! if automatic_approval_allowed?(group)
    elsif event.agile_alliance_discount_group? && AgileAllianceService.check_member(attendance.email)
      attendance.update(registration_group: event.agile_alliance_discount_group)
      attendance.accepted!
    end
    attendance
  end

  private

  def automatic_approval_allowed?(group)
    group&.automatic_approval? && group&.vacancies?
  end
end
