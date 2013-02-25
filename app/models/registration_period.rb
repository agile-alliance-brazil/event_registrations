# encoding: UTF-8
class RegistrationPeriod < ActiveRecord::Base
  belongs_to :event
  
  attr_accessible :end_at
  
  scope :for, lambda { |datetime| where('? BETWEEN start_at AND end_at', datetime).order('id desc') }

  def price_for_registration_type(registration_type)
    RegistrationPrice.for(self, registration_type).first.value
  rescue => e
    Rails.logger.error("Error fetching price for registration type #{registration_type.inspect}: #{e.message}")
    raise InvalidPrice.new("Invalid price for registration type #{registration_type.inspect}")
  end
end

class InvalidPrice < StandardError
end
