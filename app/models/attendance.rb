# encoding: UTF-8
class Attendance < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  belongs_to :registration_type
  belongs_to :registration_period
  has_many :payment_notifications, as: :invoicer

  attr_accessible :event_id, :user_id, :registration_type_id, :registration_group_id, :registration_date,
                  :first_name, :last_name, :email, :email_confirmation, :organization, :phone, :country,
                  :state, :city, :badge_name, :cpf, :gender, :twitter_user, :address, :neighbourhood,
                  :zipcode

  attr_accessor :email_confirmation

  validates_confirmation_of :email
  validates_presence_of [:first_name, :last_name]
  validates_length_of [:first_name, :last_name], :maximum => 100, :allow_blank => true
  validates_format_of :email, :with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i, :allow_blank => true

  usar_como_cpf :cpf

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

  def can_cancel?
    false
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def male?
    gender == 'M'
  end
end
