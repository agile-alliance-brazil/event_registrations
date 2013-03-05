# encoding: UTF-8
class Attendance < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  belongs_to :registration_type
  belongs_to :registration_period

  attr_accessible :event_id, :user_id, :registration_type_id, :registration_group_id, :registration_date

  state_machine :status, :initial => :pending do
    event :confirm do
      transition [:pending, :paid] => :confirmed
    end

    event :pay do
      transition :pending => :paid
    end
    
    state :confirmed do
      validates_acceptance_of :payment_agreement
    end
    
    after_transition any => :confirmed do |attendance|
      begin
        EmailNotifications.registration_confirmed(attendance).deliver
      rescue => ex
        Airbrake.notify(ex)
      end
    end
  end

  validates_presence_of :registration_type_id, :registration_date, :user_id, :event_id

  def base_price
    registration_period.price_for_registration_type(registration_type)
  end

  def registration_period
    RegistrationPeriod.for(self.registration_date).first
  end

  def registration_fee
    base_price
  end
end
