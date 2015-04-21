class Event < ActiveRecord::Base
  has_many :attendances
  has_many :registration_periods
  has_many :registration_quotas
  has_many :registration_types

  has_many :registration_groups

  def can_add_attendance?
    attendance_limit.nil? || attendance_limit == 0 || (attendance_limit > attendances.active.size)
  end

  def registration_price(type, datetime)
    quota = find_quota
    if registration_periods.present? && registration_periods.for(datetime).present?
      registration_periods.for(datetime).first.price_for_registration_type type
    elsif quota.present?
      quota.price
    else
      full_price
    end
  end

  private

  def find_quota
    registration_quotas.order(order: :asc).each { |quota| return quota if quota.have_vacancy? }
  end
end
