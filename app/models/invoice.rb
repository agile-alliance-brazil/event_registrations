# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                    :integer          not null, primary key
#  frete                 :integer
#  amount                :decimal(10, )
#  created_at            :datetime
#  updated_at            :datetime
#  user_id               :integer
#  registration_group_id :integer
#  status                :string(255)
#  payment_type          :integer          not null
#  invoiceable_type      :string(255)
#  invoiceable_id        :integer
#
# Indexes
#
#  index_invoices_on_invoiceable_type_and_invoiceable_id  (invoiceable_type,invoiceable_id)
#

class Invoice < ApplicationRecord
  STATUSES = [PENDING = 'pending', SENT = 'sent', PAID = 'paid', CANCELLED = 'cancelled'].freeze

  enum payment_type: { gateway: 1, bank_deposit: 2, statement_agreement: 3 }

  belongs_to :user
  belongs_to :invoiceable, polymorphic: true

  has_many :payment_notifications, dependent: :destroy, inverse_of: :invoice

  delegate :email, :cpf, :gender, :phone, :address, :neighbourhood, :city, :state, :zipcode, to: :user

  scope :active, -> { where.not(status: :cancelled) }
  scope :for_attendance, ->(attendance_id) { active.where(invoiceable_id: attendance_id, invoiceable_type: 'Attendance') }

  validates :payment_type, presence: true

  def self.from_attendance(attendance, payment_type = 'gateway')
    invoice = for_attendance(attendance.id).first
    return invoice if invoice.present?

    invoice = Invoice.create(
      user: attendance.user,
      amount: attendance.registration_value,
      status: Invoice::PENDING,
      invoiceable: attendance,
      payment_type: payment_type
    )

    attendance.invoices << invoice
    invoice
  end

  def self.from_registration_group(group, payment_type)
    invoice = find_by(invoiceable: group)
    if invoice.present?
      invoice.update(amount: group.total_price, payment_type: payment_type)
      return invoice
    end

    Invoice.create!(
      invoiceable: group,
      user: group.leader,
      amount: group.total_price,
      status: Invoice::PENDING,
      payment_type: payment_type
    )
  end

  def pay_it!
    update(status: Invoice::PAID)
  end

  def send_it!
    update(status: Invoice::SENT)
  end

  def cancel_it!
    update(status: Invoice::CANCELLED)
  end

  def recover_it!
    update(status: Invoice::PENDING)
  end

  def name
    invoiceable.to_s if invoiceable.present?
  end

  def pending?
    status == PENDING
  end
end
