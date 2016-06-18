class RegistrationGroupRepository
  include Singleton

  def reserved_for_quota(quota)
    RegistrationGroup.where(registration_quota_id: quota.id, paid_in_advance: true).map(&:capacity_left).inject(0, &:+)
  end

  def reserved_for_event(event)
    RegistrationGroup.where(event_id: event.id, paid_in_advance: true).map(&:capacity_left).inject(0, &:+)
  end
end
