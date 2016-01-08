# encoding: UTF-8
# == Schema Information
#
# Table name: payment_notifications
#
#  id              :integer          not null, primary key
#  params          :text(65535)
#  status          :string(255)
#  transaction_id  :string(255)
#  invoicer_id     :integer
#  payer_email     :string(255)
#  settle_amount   :decimal(10, )
#  settle_currency :string(255)
#  notes           :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#  invoicer_type   :string(255)
#
# Indexes
#
#  fk_rails_92030b1506  (invoice_id)
#

class PaymentNotification < ActiveRecord::Base
  belongs_to :invoice
  serialize :params

  after_create :mark_invoicer_as_paid, if: ->(n) { n.status == 'Completed' }
  validates :invoice, presence: true

  scope :pag_seguro, -> { where('params LIKE ?', '%type: pag_seguro%') }
  scope :completed, -> { where('status = ?', 'Completed') }

  def self.create_for_pag_seguro(params)
    attributes = from_pag_seguro_params(params)
    PaymentNotification.create!(attributes)
  end

  private

  def mark_invoicer_as_paid
    if params_valid?
      invoice.pay
      if invoice.invoiceable_type == 'Attendance'
        attendance = Attendance.where(id: invoice.invoiceable_id).last
        attendance.pay if attendance.present?
      end
    else
      Airbrake.notify("Failed Payment Notification for invoicer: #{invoice.name}", params)
    end
  end

  def params_valid?
    type = params[:type]
    send "#{type}_valid?", APP_CONFIG[type]
  end

  def pag_seguro_valid?(hash)
    params[:store_code] == hash[:store_code]
  end

  def self.from_pag_seguro_params(params)
    PagSeguroService.config
    {
      params: params,
      invoice: Invoice.find(params[:pedido]),
      status: params[:status],
      transaction_id: params[:transaction_code],
      notes: params[:transaction_inspect]
    }
  end
end
