class PerformGroupCheck
  def self.run(attendance, token)
    event = attendance.event
    group = event.registration_groups.find_by(token: token)

    if group.present? && group.accept_members?
      attendance.registration_group = group
      group.save!
    elsif AgileAllianceService.check_member(attendance.email)
      aa_group = event.registration_groups.where(name: 'Membros da Agile Alliance').first
      if aa_group.present?
        attendance.registration_group = aa_group
        attendance.accept
      end
    end

    attendance
  end
end
