# encoding: UTF-8
# == Schema Information
#
# Table name: registration_periods
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  title      :string
#  start_at   :datetime
#  end_at     :datetime
#  created_at :datetime
#  updated_at :datetime
#

class RegistrationPeriod < ActiveRecord::Base
  belongs_to :event

  scope :for, ->(datetime) { where('? BETWEEN start_at AND end_at', datetime).order('id desc') }
  scope :ending_after, ->(datetime) { where('? < end_at', datetime).order('id desc') }

  def price_for
    prices_for.first.value
  rescue
    raise InvalidPrice, 'Invalid price for registration period'
  end

  def super_early_bird?
    title == 'registration_period.super_early_bird'
  end

  def early_bird?
    title == 'registration_period.early_bird'
  end

  def allow_voting?
    event.allow_voting? && (super_early_bird? || early_bird?)
  end

  private

  def prices_for
    RegistrationPrice.for(self)
  end
end

class InvalidPrice < StandardError
end
