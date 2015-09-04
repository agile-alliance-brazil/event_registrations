# == Schema Information
#
# Table name: registration_groups
#
#  id           :integer          not null, primary key
#  event_id     :integer
#  name         :string
#  capacity     :integer
#  discount     :integer
#  token        :string
#  created_at   :datetime
#  updated_at   :datetime
#  leader_id    :integer
#  invoice_id   :integer
#  minimum_size :integer
#  amount       :decimal(, )
#

class RegistrationGroup < ActiveRecord::Base
  belongs_to :event
  belongs_to :leader, class_name: 'User', inverse_of: :led_groups

  has_many :attendances
  has_many :invoices

  validates :event, presence: true

  before_create :generate_token

  before_destroy do |record|
    group_attendances = Attendance.where(registration_group_id: record.id)
    if group_attendances.map(&:can_cancel?).all?
      group_attendances.map(&:cancel)
    else
      false
    end
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
    minimum_size > 1
  end

  def complete?
    attendances.paid.count >= minimum_size
  end

  private

  def generate_token
    self.token = SecureRandom.hex
  end
end
