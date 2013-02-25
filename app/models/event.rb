# encoding: UTF-8
class Event < ActiveRecord::Base
  has_many :event_attendances
  
  def self.current
    order('year desc').first
  end
end
