# encoding: UTF-8
# == Schema Information
#
# Table name: payment_notifications
#
#  id              :integer          not null, primary key
#  params          :text
#  status          :string
#  transaction_id  :string
#  invoicer_id     :integer
#  payer_email     :string
#  settle_amount   :decimal(, )
#  settle_currency :string
#  notes           :text
#  created_at      :datetime
#  updated_at      :datetime
#  invoicer_type   :string
#

class PaymentNotification < ActiveRecord::Base
  belongs_to :invoicer, polymorphic: true
  serialize :params

  validates :invoicer, presence: true

  after_create :mark_invoicer_as_paid, if: ->(n) { n.status == 'Completed' }

  scope :pag_seguro, -> { where('params LIKE ?', '%type: pag_seguro%') }
  scope :completed, -> { where('status = ?', 'Completed') }

  def self.create_for_pag_seguro(params)
    attributes = from_pag_seguro_params(params)
    PaymentNotification.create!(attributes)
  end

  private

  def mark_invoicer_as_paid
    if params_valid? && invoicer.respond_to?(:pay)
      invoicer.pay
    else
      Airbrake.notify(
        error_class:   'Failed Payment Notification',
        error_message: "Failed Payment Notification for invoicer: #{invoicer.inspect}",
        parameters:    params
      )
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
      invoicer: Invoice.find(params[:pedido]),
      status: params[:status],
      transaction_id: params[:transaction_code],
      notes: params[:transaction_inspect]
    }
  end
end
