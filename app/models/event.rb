# encoding: UTF-8
class Event < ActiveRecord::Base
  has_many :event_attendances
  has_many :registration_periods
  
  def self.current
    order('year desc').first
  end
end
