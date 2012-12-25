# encoding: UTF-8
class PreRegistration < ActiveRecord::Base
  belongs_to :event

  attr_accessible :event, :email, :used
  
  scope :registered, lambda {|email| where('UPPER(email) = UPPER(?)', email) }
end
