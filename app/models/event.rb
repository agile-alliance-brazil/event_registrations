class Event < ActiveRecord::Base
  has_many :attendances
  has_many :registration_periods
  has_many :registration_quotas
  has_many :registration_types

  has_many :registration_groups

  delegate :attendances_for, to: :attendances

  scope :active_for, ->(date) { where('end_date > ?', date) }

  def can_add_attendance?
    attendance_limit.nil? || attendance_limit == 0 || (attendance_limit > attendances.active.size)
  end

  def registration_price_for(attendance, payment_type)
    group = attendance.registration_group
    return group.amount if group.present? && group.amount.present? && group.amount > 0
    not_amounted_group(attendance, payment_type)
  end

  def period_for(today = Time.zone.today)
    registration_periods.for(today).first if registration_periods.present?
  end

  def find_quota
    registration_quotas.order(order: :asc).select(&:vacancy?)
  end

  def free?(attendance)
    !registration_types.paid.include?(attendance.registration_type)
  end

  private

  def not_amounted_group(attendance, payment_type)
    quota = find_quota
    if payment_type == Invoice::STATEMENT
      full_price
    elsif period_for.present?
      period_for.price_for_registration_type(attendance.registration_type) * attendance.discount
    elsif quota.first.present?
      quota.first.price * attendance.discount
    else
      full_price * attendance.discount
    end
  end
end
