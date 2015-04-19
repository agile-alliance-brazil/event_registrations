class RegistrationQuota < ActiveRecord::Base

  belongs_to :event
  belongs_to :registration_price

  has_many :attendances

  def have_vacancy?
    attendances.size < quota
  end

  def price
    registration_price.value
  end

end
