class RegistrationQuota < ActiveRecord::Base
  belongs_to :event
  belongs_to :registration_price

  has_many :attendances

  def vacancy?
    open? && attendances.active.size < quota
  end

  def price
    registration_price.value
  end

  private

  def open?
    !closed
  end
end
