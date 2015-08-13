module Concerns
  module Groupable
    extend ActiveSupport::Concern

    def perform_group_check!
      group = @event.registration_groups.find_by(token: params['registration_token'])

      if group.present? && group.accept_members?
        @attendance.registration_group = group
        group.save!
      elsif AgileAllianceService.check_member(@attendance.email)
        aa_group = RegistrationGroup.find_by(name: 'Membros da Agile Alliance')
        @attendance.registration_group = aa_group
        @attendance.accept
      end
    end
  end
end
