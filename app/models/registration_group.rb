class RegistrationGroup < ActiveRecord::Base
  belongs_to :event
  has_many :attendances

  validates :event, presence: true

  before_create :generate_token

  def qtd_attendances
    attendances.size
  end

  private

  def generate_token
    self.token = SecureRandom.hex
  end
end
