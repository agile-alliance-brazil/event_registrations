# encoding: UTF-8
class RegistrationType < ActiveRecord::Base
  belongs_to :event
  has_many :registration_prices
  
  scope :without_group, where('id <> ?', 2)
  scope :without_free, where('id <> ? AND  id <> ?', 3, 4)
  
  def price(datetime)
    period = RegistrationPeriod.for(datetime).first
    period.price_for_registration_type(self)
  end
end
