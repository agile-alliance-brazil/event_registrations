class Invoice < ActiveRecord::Base
  STATUSES = [PENDING = 'pending', SENT = 'sent', PAID = 'paid', CANCELLED = 'cancelled']

  belongs_to :user
  belongs_to :registration_group

  delegate :email, :cpf, :gender, :phone, :address, :neighbourhood, :city, :state, :zipcode, to: :user

  def self.from_attendance(attendance)
    invoice = find_by(user: attendance.user)
    return invoice if invoice.present? && invoice.amount == attendance.registration_value
    invoice.destroy if invoice.present?
    Invoice.create!(user: attendance.user, amount: attendance.registration_value, status: Invoice::PENDING)
  end

  def self.from_registration_group(group)
    invoice = find_by(registration_group: group)
    return invoice if invoice.present? && invoice.amount == group.total_price
    invoice.destroy if invoice.present?
    Invoice.create!(registration_group: group, user: group.leader, amount: group.total_price, status: Invoice::PENDING)
  end

  def registration_value
    amount
  end

  def pay
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

  def name
    return user.full_name unless registration_group.present?
    registration_group.name
  end

  def pending?
    status == PENDING
  end
end
