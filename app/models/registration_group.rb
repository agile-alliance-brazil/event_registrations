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

class RegistrationGroup < ActiveRecord::Base
  belongs_to :event
  belongs_to :leader, class_name: 'User', inverse_of: :led_groups
  belongs_to :registration_quota

  has_many :attendances
  has_many :invoices, as: :invoiceable

  validates :event, :name, presence: true
  validates :capacity, :amount, presence: true, if: :paid_in_advance?
  validate :enough_capacity, if: :paid_in_advance?

  before_create :generate_token

  before_destroy do |record|
    group_attendances = Attendance.where(registration_group_id: record.id)
    group_attendances.map(&:cancel)
  end

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
    return false unless minimum_size.present?
    attendances.paid.count < minimum_size
  end

  def capacity_left
    capacity - attendances.active.count
  end

  private

  def generate_token
    self.token = SecureRandom.hex
  end

  def enough_capacity
    return unless capacity.present?
    if registration_quota.present? && registration_quota.capacity_left < capacity
      errors.add(:capacity, I18n.t('registration_group.quota_capacity_error'))
    elsif event.capacity_left < capacity
      errors.add(:capacity, I18n.t('registration_group.event_capacity_error'))
    end
  end
end
