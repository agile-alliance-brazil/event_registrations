# == Schema Information
#
# Table name: registration_groups
#
#  amount             :decimal(10, )
#  automatic_approval :boolean          default(FALSE)
#  capacity           :integer
#  created_at         :datetime
#  discount           :integer
#  event_id           :integer
#  id                 :integer          not null, primary key
#  invoice_id         :integer
#  leader_id          :integer
#  minimum_size       :integer
#  name               :string(255)
#  token              :string(255)
#  updated_at         :datetime
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

  has_many :attendances
  has_many :invoices, as: :invoiceable

  validates :event, :name, presence: true

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
    attendances.paid.count < minimum_size
  end

  private

  def generate_token
    self.token = SecureRandom.hex
  end
end
