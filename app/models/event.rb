# encoding: UTF-8
class Event < ActiveRecord::Base
  def self.current
    order('year desc').first
  end
end
