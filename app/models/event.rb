# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  allow_voting       :boolean
#  attendance_limit   :integer
#  city               :string(255)      not null
#  country            :string(255)      not null
#  created_at         :datetime
#  days_to_charge     :integer          default(7)
#  end_date           :datetime
#  event_image        :string(255)
#  full_price         :decimal(10, )
#  id                 :integer          not null, primary key
#  link               :string(255)
#  location_and_date  :string(255)
#  logo               :string(255)
#  main_email_contact :string(255)      default(""), not null
#  name               :string(255)
#  price_table_link   :string(255)
#  start_date         :datetime
#  state              :string(255)      not null
#  updated_at         :datetime
#

class Event < ApplicationRecord
  mount_uploader :event_image, RegistrationsImageUploader

  has_many :attendances, dependent: :restrict_with_exception
  has_many :registration_periods, dependent: :destroy
  has_many :registration_quotas, dependent: :destroy

  has_many :registration_groups, dependent: :destroy

  has_and_belongs_to_many :organizers, class_name: 'User'

  validates :start_date, :end_date, :full_price, :name, :main_email_contact, :attendance_limit, :country, :state, :city, presence: true
  validate :period_valid?

  scope :active_for, ->(date) { where('end_date > ?', date) }
  scope :not_started, -> { where('start_date > ?', Time.zone.today) }
  scope :ended, -> { where('end_date < ?', Time.zone.today) }
  scope :tomorrow_events, -> { where(start_date: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }

  def full?
    places_sold = reserved_count + attendances.active.size
    attendance_limit.present? && attendance_limit.positive? && (attendance_limit <= places_sold)
  end

  def registration_price_for(attendance, payment_type)
    group = attendance.registration_group
    return group.amount if group.present? && group.amount.present? && group.amount.positive?

    extract_value(attendance, payment_type)
  end

  def period_for(now = Time.zone.now)
    registration_periods.for(now).first if registration_periods.present?
  end

  def find_quota
    registration_quotas.order(order: :asc).select(&:vacancy?)
  end

  def started
    Time.zone.today >= start_date
  end

  def add_organizer(user)
    organizers << user unless organizers.include?(user)
    save
  end

  def remove_organizer(user)
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

  def capacity_left
    attendance_limit - (attendances.active.size + reserved_count)
  end

  def attendances_count
    attendances.active.count + reserved_count
  end

  def reserved_count
    RegistrationGroupRepository.instance.reserved_for_event(self)
  end

  def average_ticket
    attendances_confirmed = attendances.committed_to
    return 0 if attendances_confirmed.empty?

    attendances_confirmed.sum(:registration_value) / attendances_confirmed.count
  end

  def ended?
    end_date < Time.zone.now
  end

  private

  def extract_value(attendance, payment_type)
    quota = find_quota
    if payment_type == 'statement_agreement'
      full_price
    elsif attendance.price_band?
      attendance.band_value * attendance.discount
    elsif period_for.present?
      period_for.price * attendance.discount
    elsif quota.first.present?
      quota.first.price * attendance.discount
    else
      (full_price || 0) * attendance.discount
    end
  end

  def period_valid?
    return unless start_date.present? && end_date.present?

    errors.add(:end_date, I18n.t('activerecord.errors.models.event.attributes.end_date.invalid_period')) if start_date > end_date
  end
end
