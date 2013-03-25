# encoding: UTF-8
class RegistrationPeriod < ActiveRecord::Base
  SUPER_EARLY_LIMIT = 150

  belongs_to :event
  
  attr_accessible :end_at
  
  scope :for, lambda { |datetime| where('? BETWEEN start_at AND end_at', datetime).order('id desc') }

  def price_for_registration_type(registration_type)
    prices_for(registration_type).first.value
  rescue => e
    Rails.logger.error("Error fetching price for registration type #{registration_type.inspect}: #{e.message}")
    raise InvalidPrice.new("Invalid price for registration type #{registration_type.inspect}")
  end

  def super_early_bird?
    title == "registration_period.super_early_bird"
  end

  private
  def prices_for(registration_type)
    if(super_early_bird? && Attendance.where(event_id: event.id).count >= SUPER_EARLY_LIMIT)
      next_period = RegistrationPeriod.for(end_at + 1.day).first
      RegistrationPrice.for(next_period, registration_type)
    else
      RegistrationPrice.for(self, registration_type)
    end
  end
end

class InvalidPrice < StandardError
end
