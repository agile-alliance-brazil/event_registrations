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

  private

  def generate_token
    self.token = SecureRandom.hex
  end
end
