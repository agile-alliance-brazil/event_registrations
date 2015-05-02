# encoding: UTF-8
class Attendance < ActiveRecord::Base
  SUPER_EARLY_LIMIT = 150

  belongs_to :event
  belongs_to :user
  belongs_to :registration_type
  belongs_to :registration_period
  belongs_to :registration_group
  belongs_to :registration_quota
  has_many :payment_notifications, as: :invoicer

  validates_confirmation_of :email
  validates_presence_of [:first_name, :last_name, :email, :phone, :country, :city]
  validates_presence_of :state, if: ->(a) {a.in_brazil?}
  validates_presence_of :cpf, if: ->(a) {a.in_brazil?}

  validates_length_of [:first_name, :last_name, :phone, :city, :organization], maximum: 100, allow_blank: true
  validates_format_of :email, with: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, allow_blank: true
  validates_length_of :email, within: 6..100, allow_blank: true

  validates_format_of :phone, with: /\A[0-9\(\) .\-\+]+\Z/i, allow_blank: true

  delegate :token, to: :registration_group
  delegate :name, to: :registration_group, prefix: :group, allow_nil: true

  usar_como_cpf :cpf

  state_machine :status, initial: :pending do
    after_transition on: :pay, do: :pay_invoice!
    after_transition on: :cancel, do: :cancel_invoice!

    event :confirm do
      transition [:pending, :paid] => :confirmed
    end

    event :pay do
      transition [:pending, :confirmed] => :paid
    end

    event :cancel do
      transition pending: :cancelled
    end

    state :confirmed do
      validates_acceptance_of :payment_agreement
    end

    after_transition any => :confirmed do |attendance|
      begin
        EmailNotifications.registration_confirmed(attendance).deliver_now
      rescue => ex
        Airbrake.notify(ex)
      end
    end
  end

  validates_presence_of :registration_type_id, :registration_date, :user_id, :event_id

  scope :for_event, ->(e) { where(event_id: e.id) }
  scope :for_registration_type, ->(t) { where(registration_type_id: t.id) }
  scope :without_registration_type, ->(t) { where("#{table_name}.registration_type_id != (?)", t.id) }
  scope :pending, -> { where(status: :pending) }
  scope :paid, -> { where(status: [:paid, :confirmed]) }
  scope :active, -> { where('status != (?)', :cancelled) }
  scope :older_than, ->(date) { where('registration_date < (?)', date) }
  scope :search_for_list, lambda { |param|
    where('first_name LIKE ? OR last_name LIKE ? OR organization LIKE ? OR email LIKE ?',
    "%#{param}%", "%#{param}%", "%#{param}%", "%#{param}%")
  }
  scope :attendances_for, ->(user_param) { where('user_id = ?', user_param.id).order(created_at: :asc) }

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

  def discount
    amount = 1
    amount = 1 - (registration_group.discount / 100.00) if registration_group.present?
    amount
  end

  private

  def entitled_super_early_bird?
    attendances = event.attendances
    attendances = attendances.where('id < ?', id) unless new_record?
    attendances.count < SUPER_EARLY_LIMIT
  end

  def pay_invoice!
    invoice = user.invoices.where(status: 'pending').last
    return unless invoice.present?
    invoice.pay_it
    invoice.save!
  end

  def cancel_invoice!
    invoice = user.invoices.where(status: 'pending').last
    return unless invoice.present?
    invoice.cancel_it
    invoice.save!
  end
end
