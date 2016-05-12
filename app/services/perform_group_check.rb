class PerformGroupCheck
  def self.run(attendance, token)
    event = attendance.event
    group = event.registration_groups.find_by(token: token)

    if group.present? && group.accept_members?
      attendance.registration_group = group
      attendance.accept if group.automatic_approval?
      group.save!
    elsif event.agile_alliance_discount_group? && AgileAllianceService.check_member(attendance.email)
      attendance.registration_group = event.agile_alliance_discount_group
      attendance.accept
    end

    attendance
  end
end
