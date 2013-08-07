# encoding: UTF-8
class RegistrationPeriod < ActiveRecord::Base
  belongs_to :event
  
  scope :for, lambda { |datetime| where('? BETWEEN start_at AND end_at', datetime).order('id desc') }
  scope :ending_after, lambda { |datetime| where('? < end_at', datetime).order('id desc') }

  def price_for_registration_type(registration_type)
    prices_for(registration_type).first.value
  rescue => e
    Rails.logger.error("Error fetching price for registration type #{registration_type.inspect}: #{e.message}")
    raise InvalidPrice.new("Invalid price for registration type #{registration_type.inspect}")
  end

  def super_early_bird?
    title == "registration_period.super_early_bird"
  end

  def early_bird?
    title == "registration_period.early_bird"
  end

  def allow_voting?
    event.allow_voting? && (super_early_bird? || early_bird?)
  end

  private
  def prices_for(registration_type)
    RegistrationPrice.for(self, registration_type)
  end
end

class InvalidPrice < StandardError
end
