module Concerns
  module Groupable
    extend ActiveSupport::Concern

    def perform_group_check!
      group = @event.registration_groups.find_by_token(params['registration_token'])
      @attendance.registration_group = group if group.present? && group.accept_members?

      return unless AgileAllianceService.check_member(@attendance.email) && !group.present?
      group = RegistrationGroup.find_by(name: 'Membros da Agile Alliance')
      @attendance.registration_group = group
      @attendance.accept
    end
  end
end
