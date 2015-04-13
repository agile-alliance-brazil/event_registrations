class Invoice < ActiveRecord::Base
  STATUSES = [PENDING = 'pending', SENT = 'sent', PAID = 'paid']

  belongs_to :user
  belongs_to :registration_group

  delegate :email, :cpf, :gender, :phone, :address, :neighbourhood, :city, :state, :zipcode, to: :user

  def self.from_attendance(attendance)
    invoice = find_by(user: attendance.user)
    return invoice if invoice.present?
    Invoice.create!(user: attendance.user, amount: attendance.event.registration_price_for(attendance), status: Invoice::PENDING)
  end

  def self.from_registration_group(group)
    invoice = find_by(registration_group: group)
    return invoice if invoice.present?
    Invoice.create!(registration_group: group, user: group.leader, amount: group.total_price, status: Invoice::PENDING)
  end

  def pay_it
    self.status = Invoice::PAID
  end

  def send_it
    self.status = Invoice::SENT
  end

  def name
    return user.full_name unless registration_group.present?
    registration_group.name
  end

  def pending?
    status == PENDING
  end

  def amount
    return attendance.registration_fee unless registration_group.present?
    registration_group.total_price
  end
end
