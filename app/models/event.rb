# == Schema Information
#
# Table name: events
#
#  allow_voting       :boolean
#  attendance_limit   :integer
#  created_at         :datetime
#  days_to_charge     :integer          default(7)
#  end_date           :datetime
#  full_price         :decimal(10, )
#  id                 :integer          not null, primary key
#  link               :string(255)
#  location_and_date  :string(255)
#  logo               :string(255)
#  main_email_contact :string(255)      not null
#  name               :string(255)
#  price_table_link   :string(255)
#  start_date         :datetime
#  updated_at         :datetime
#

class Event < ActiveRecord::Base
  has_many :attendances
  has_many :registration_periods
  has_many :registration_quotas

  has_many :registration_groups

  has_and_belongs_to_many :organizers, class_name: 'User'

  validates :start_date, :end_date, :full_price, :name, :main_email_contact, presence: true
  validate :period_valid?

  scope :active_for, ->(date) { where('end_date > ?', date) }
  scope :not_started, -> { where('start_date > ?', Time.zone.today) }
  scope :ended, -> { where('end_date < ?', Time.zone.today) }
  scope :tomorrow_events, -> { where(start_date: 1.day.from_now.beginning_of_day..1.day.from_now.end_of_day) }

  def full?
    attendance_limit.present? && attendance_limit > 0 && (attendance_limit <= attendances.active.size)
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

  def started
    Time.zone.today >= start_date
  end

  def add_organizer_by_email!(email)
    user = User.find_by(email: email)
    return false unless user.present? && (user.organizer? || user.admin?)
    organizers << user unless organizers.include?(user)
    save
  end

  def remove_organizer_by_email!(email)
    user = User.find_by(email: email)
    return false unless user.present?
    organizers.delete(user)
    save
  end

  def contains?(user)
    attendances.active.where(user: user).present?
  end

  def attendances_in_the_queue?
    !attendances.waiting.empty?
  end

  def queue_average_time
    attendances_passed_by_queue = attendances.active.with_time_in_queue
    return 0 if attendances_passed_by_queue.empty?
    attendances_passed_by_queue.sum(:queue_time) / attendances_passed_by_queue.count
  end

  def agile_alliance_discount_group?
    agile_alliance_discount_group.present?
  end

  def agile_alliance_discount_group
    registration_groups.find_by(name: 'Membros da Agile Alliance')
  end

  private

  def not_amounted_group(attendance, payment_type)
    value = extract_value(attendance, payment_type)
    Money.new(value, :BRL)
  end

  def extract_value(attendance, payment_type)
    quota = find_quota
    if payment_type == Invoice::STATEMENT
      (full_price * 100)
    elsif period_for.present?
      period_for.price * attendance.discount
    elsif quota.first.present?
      quota.first.price * attendance.discount
    else
      (full_price * 100) * attendance.discount
    end
  end

  def period_valid?
    return unless start_date.present? && end_date.present?
    errors.add(:end_date, :invalid_period) if start_date > end_date
  end
end
