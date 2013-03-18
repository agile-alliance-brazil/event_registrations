# encoding: UTF-8
class Event < ActiveRecord::Base
  has_many :attendances
  has_many :registration_periods
  has_many :registration_types
  
  def self.current
    order('year desc').first
  end
end
