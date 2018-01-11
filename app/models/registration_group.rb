# == Schema Information
#
# Table name: registration_groups
#
#  amount                :decimal(10, )
#  automatic_approval    :boolean          default(FALSE)
#  capacity              :integer
#  created_at            :datetime
#  discount              :integer
#  event_id              :integer
#  id                    :integer          not null, primary key
#  invoice_id            :integer
#  leader_id             :integer
#  minimum_size          :integer
#  name                  :string
#  paid_in_advance       :boolean          default(FALSE)
#  registration_quota_id :integer
#  token                 :string
#  updated_at            :datetime
#
# Indexes
#
#  fk_rails_9544e3707e  (invoice_id)
#
# Foreign Keys
#
#  fk_rails_9544e3707e  (invoice_id => invoices.id)
#

class RegistrationGroup < ApplicationRecord
  belongs_to :event
  belongs_to :leader, class_name: 'User', inverse_of: :led_groups
  belongs_to :registration_quota

  before_destroy do |record|
    group_attendances = Attendance.where(registration_group_id: record.id)
    group_attendances.map(&:cancel)
  end

  has_many :attendances, dependent: :nullify
  has_many :invoices, as: :invoiceable, dependent: :restrict_with_exception, inverse_of: :invoiceable

  validates :event, :name, presence: true
  validates :capacity, :amount, presence: true, if: :paid_in_advance?
  validates :discount, numericality: { greater_than: 0 }, allow_nil: true
  validate :enough_capacity, if: :paid_in_advance?
  validate :discount_or_amount_present?

  before_create :generate_token

  def to_s
    name
  end

  def qtd_attendances
    attendances.active.size
  end

  def total_price
    attendances.active.map(&:registration_value).sum
  end

  def price?
    total_price > 0
  end

  def leader_name
    leader.full_name if leader
  end

  def update_invoice
    return if invoices.blank?
    invoice = invoices.last
    return unless invoice.pending?
    invoice.amount = total_price
    invoice.save!
  end

  def accept_members?
    true
  end

  def paid?
    attendances.map(&:paid?).any?
  end

  def free?
    discount == 100
  end

  def floor?
    minimum_size.to_i > 1
  end

  def incomplete?
    return false if minimum_size.blank?
    attendances.paid.count < minimum_size
  end

  def capacity_left
    return 0 if capacity.blank?
    capacity - attendances.active.count
  end

  def vacancies?
    return true if capacity.blank? || capacity.zero?
    capacity_left > 0
  end

  private

  def generate_token
    self.token = SecureRandom.hex
  end

  def enough_capacity
    return if capacity.blank?
    if registration_quota.present? && registration_quota.capacity_left < capacity
      errors.add(:capacity, I18n.t('registration_group.quota_capacity_error'))
    elsif event.capacity_left < capacity
      errors.add(:capacity, I18n.t('registration_group.event_capacity_error'))
    end
  end

  def discount_or_amount_present?
    return true if discount.present? || amount.present?
    errors.add(:discount, I18n.t('registration_group.errors.discount_or_amount_present'))
    errors.add(:amount, I18n.t('registration_group.errors.discount_or_amount_present'))
  end
end
