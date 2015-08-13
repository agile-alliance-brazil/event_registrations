class Invoice < ActiveRecord::Base
  STATUSES = [PENDING = 'pending', SENT = 'sent', PAID = 'paid', CANCELLED = 'cancelled']
  TYPES = [GATEWAY = 'gateway', DEPOSIT = 'bank_deposit', STATEMENT = 'statement_agreement']

  belongs_to :user
  belongs_to :registration_group

  has_many :invoice_attendances
  has_many :attendances, -> { uniq }, through: :invoice_attendances

  delegate :email, :cpf, :gender, :phone, :address, :neighbourhood, :city, :state, :zipcode, to: :user

  scope :active, -> { where.not(status: :cancelled) }
  scope :individual, -> { where(registration_group: nil) }
  scope :for_attendance, ->(attendance_id) { active.individual.includes(:attendances).where('attendances.id = ?', attendance_id).references(:attendances) }

  validates :payment_type, presence: true

  def self.from_attendance(attendance, payment_type)
    invoice = for_attendance(attendance.id).first
    return invoice if invoice.present?

    Invoice.create(
      user: attendance.user,
      amount: attendance.registration_value,
      status: Invoice::PENDING,
      attendances: [attendance],
      payment_type: payment_type
    )
  end

  def self.from_registration_group(group, payment_type)
    invoice = find_by(registration_group: group)
    if invoice.present?
      invoice.update_attributes(amount: group.total_price, payment_type: payment_type)
      invoice.attendances << group.attendances
      return invoice
    end

    Invoice.create!(
      registration_group: group,
      user: group.leader,
      amount: group.total_price,
      status: Invoice::PENDING,
      attendances: group.attendances,
      payment_type: payment_type
    )
  end

  def add_attendances(*items)
    offset = items - attendances
    attendances.concat(*offset)
  end

  def registration_value
    amount
  end

  def pay
    return unless attendances.map(&:pay).reduce(true, &:&)
    pay_it
    save!
  end

  def pay_it
    self.status = Invoice::PAID
  end

  def send_it
    self.status = Invoice::SENT
  end

  def cancel_it
    self.status = Invoice::CANCELLED
  end

  def recover_it
    self.status = Invoice::PENDING
  end

  def name
    return user.full_name unless registration_group.present?
    registration_group.name
  end

  def pending?
    status == PENDING
  end
end
