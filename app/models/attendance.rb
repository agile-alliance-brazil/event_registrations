# encoding: UTF-8
class Attendance < ActiveRecord::Base
  SUPER_EARLY_LIMIT = 150

  belongs_to :event
  belongs_to :user
  belongs_to :registration_type
  belongs_to :registration_period
  has_many :payment_notifications, foreign_key: :invoicer_id

  validates_confirmation_of :email
  validates_presence_of [:first_name, :last_name, :email, :phone, :country, :city]
  validates_presence_of :state, :if => Proc.new {|a| a.in_brazil?}
  validates_presence_of :cpf, :if => Proc.new {|a| a.in_brazil?}

  validates_length_of [:first_name, :last_name, :phone, :city, :organization], maximum: 100, allow_blank: true
  validates_format_of :email, with: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, allow_blank: true
  validates_length_of :email, within: 6..100, allow_blank: true

  validates_format_of :phone, with: /\A[0-9\(\) .\-\+]+\Z/i, allow_blank: true

  usar_como_cpf :cpf

  state_machine :status, initial: :pending do
    event :confirm do
      transition [:pending, :paid] => :confirmed
    end

    event :pay do
      transition pending: :paid
    end

    event :cancel do
      transition pending: :cancelled
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

  scope :for_event, ->(e) { where(event_id: e.id)}
  scope :for_registration_type, ->(t) { where(registration_type_id: t.id)}
  scope :without_registration_type, ->(t) { where("#{table_name}.registration_type_id != (?)", t.id)}
  scope :pending, -> { where(status: :pending)}
  scope :paid, -> { where(status: [:paid, :confirmed])}
  scope :active, -> {  where("#{table_name}.status != (?)", :cancelled)}
  scope :older_than, ->(date) { where('registration_date < (?)', date)}

  def base_price
    Rails.logger.warn('Attendance#base_price is deprecated. It was called from ' + caller[1..5].join('\n'))
    registration_fee
  end

  def registration_period
    period = event.registration_periods.for(self.registration_date).first
    if period.super_early_bird? && !entitled_super_early_bird?
      period = event.registration_periods.for(period.end_at + 1.day).first
    end
    period
  end

  def registration_fee(overriden_registration_type = nil)
    registration_period.price_for_registration_type(overriden_registration_type || registration_type)
  end

  def cancellable?
    pending?
  end

  def can_vote?
    (self.confirmed? || self.paid?) && event.registration_periods.for(self.registration_date).any?(&:allow_voting?)
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def male?
    gender == 'M'
  end

  def in_brazil?
    self.country == "BR"
  end

  private
  def entitled_super_early_bird?
    attendances = event.attendances
    if !new_record?
      attendances = attendances.where('id < ?', id)
    end
    attendances.count < SUPER_EARLY_LIMIT
  end
end
