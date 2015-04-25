class Event < ActiveRecord::Base
  has_many :attendances
  has_many :registration_periods
  has_many :registration_quotas
  has_many :registration_types

  has_many :registration_groups

  def can_add_attendance?
    attendance_limit.nil? || attendance_limit == 0 || (attendance_limit > attendances.active.size)
  end

  def registration_price_for(attendance)
    quota = find_quota
    today = Time.zone.today
    if registration_periods.present? && registration_periods.for(today).present?
      registration_periods.for(today).first.price_for_registration_type(attendance.registration_type) * attendance.discount
    elsif quota.present?
      quota.price * attendance.discount
    else
      full_price * attendance.discount
    end
  end

  def free?(attendance)
    !registration_types.paid.include?(attendance.registration_type)
  end

  private

  def find_quota
    registration_quotas.order(order: :asc).each { |quota| return quota if quota.vacancy? }
  end
end
