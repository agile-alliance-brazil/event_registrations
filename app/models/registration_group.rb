class RegistrationGroup < ActiveRecord::Base
  belongs_to :event
  belongs_to :leader, class_name: 'User', inverse_of: :led_groups

  has_many :attendances
  has_many :invoices

  validates :event, presence: true

  before_create :generate_token

  def qtd_attendances
    attendances.size
  end

  def total_price
    attendances.map(&:registration_fee).sum
  end

  def has_price?
    total_price > 0
  end

  def leader_name
    leader.full_name if leader
  end

  def update_invoice
    invoice = invoices.last
    if invoice.pending?
      invoice.amount = total_price
      invoice.save!
    end
  end

  def accept_members?
    invoices.present? ? invoices.last.pending? : true
  end

  private

  def generate_token
    self.token = SecureRandom.hex
  end
end
