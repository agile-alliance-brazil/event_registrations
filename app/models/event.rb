# encoding: UTF-8
class Event < ActiveRecord::Base
  has_many :attendances
  has_many :registration_periods
  has_many :registration_types

  def can_add_attendance?
    attendance_limit.nil? || attendance_limit == 0 || attendances.size < attendance_limit
  end
end
