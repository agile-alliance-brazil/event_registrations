# frozen_string_literal: true

class RegistrationGroupRepository
  include Singleton

  def reserved_for_quota(quota)
    RegistrationGroup.where(registration_quota_id: quota.id, paid_in_advance: true).sum(&:capacity_left)
  end

  def reserved_for_event(event)
    RegistrationGroup.where(event_id: event.id, paid_in_advance: true).sum(&:capacity_left)
  end
end
