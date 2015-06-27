# encoding: UTF-8
class Attendance < ActiveRecord::Base
  include Concerns::LifeCycle

  SUPER_EARLY_LIMIT = 150

  belongs_to :event
  belongs_to :user
  belongs_to :registration_type
  belongs_to :registration_period
  belongs_to :registration_group
  belongs_to :registration_quota
  has_many :payment_notifications, as: :invoicer

  has_many :invoice_attendances
  has_many :invoices, -> { uniq }, through: :invoice_attendances

  validates_confirmation_of :email
  validates_presence_of [:first_name, :last_name, :email, :phone, :country, :city, :registration_type_id, :registration_date, :user_id, :event_id]
  validates_presence_of :state, if: ->(a) { a.in_brazil? }
  validates_presence_of :cpf, if: ->(a) { a.in_brazil? }

  validates_length_of [:first_name, :last_name, :phone, :city, :organization], maximum: 100, allow_blank: true
  validates_format_of :email, with: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, allow_blank: true
  validates_length_of :email, within: 6..100, allow_blank: true

  validates_format_of :phone, with: /\A[0-9\(\) .\-\+]+\Z/i, allow_blank: true

  delegate :token, to: :registration_group
  delegate :name, to: :registration_group, prefix: :group, allow_nil: true

  usar_como_cpf :cpf

  scope :for_event, ->(e) { where(event_id: e.id) }
  scope :for_registration_type, ->(t) { where(registration_type_id: t.id) }
  scope :without_registration_type, ->(t) { where("#{table_name}.registration_type_id != (?)", t.id) }
  scope :active, -> { where('status != (?)', :cancelled) }
  scope :older_than, ->(date) { where('registration_date < (?)', date) }
  scope :search_for_list, lambda { |param|
    where('first_name LIKE ? OR last_name LIKE ? OR organization LIKE ? OR email LIKE ? OR id = ?',
    "%#{param}%", "%#{param}%", "%#{param}%", "%#{param}%", "#{param}").order(created_at: :desc)
  }
  scope :attendances_for, ->(user_param) { where('user_id = ?', user_param.id).order(created_at: :asc) }
  scope :pending_gateway, -> { pending.joins(:invoices).where('invoices.payment_type = ?', Invoice::GATEWAY) }

  def can_vote?
    (self.confirmed? || self.paid?) && event.registration_periods.for(self.registration_date).any?(&:allow_voting?)
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def in_brazil?
    self.country == 'BR'
  end

  def discount
    amount = 1
    amount = 1 - (registration_group.discount / 100.00) if registration_group.present?
    amount
  end

  def payment_type
    invoices.individual.last.payment_type if invoices.present?
  end

  def grouped?
    registration_group.present?
  end

  private

  def cancel_invoice!
    invoice = user.invoices.where(status: 'pending').last
    return unless invoice.present?
    invoice.cancel_it
    invoice.save!
  end
end
