# encoding: UTF-8
class PaymentNotification < ActiveRecord::Base
  belongs_to :invoicer, polymorphic: true
  serialize :params
  
  validates_existence_of :invoicer
  
  after_create :mark_invoicer_as_paid, if: ->(n) {n.status == "Completed"}
  
  def self.from_paypal_params(params)
    {
      params: params,
      invoicer_id: params[:invoice],
      status: params[:payment_status],
      transaction_id: params[:txn_id],
      notes: params[:memo]
    }
  end
  
  def self.from_bcash_params(params)
    {
      params: params,
      invoicer_id: params[:pedido],
      status: params[:status] == "Aprovada" ? "Completed" : params[:status],
      transaction_id: params[:transacao_id]
    }
  end

  def self.from_pag_seguro_params(params)
    PagSeguroService.config
    transaction = PagSeguro::Transaction.find_by_notification_code(params[:notificationCode])

    {
      params: params,
      invoicer_id: params[:pedido],
      status: transaction.status.paid? ? "Completed" : transaction.status.status,
      transaction_id: transaction.code,
      notes: transaction.inspect
    }
  end

  scope :paypal, -> { where('params LIKE ?', '%type: paypal%')}
  scope :bcash, -> { where('params LIKE ?', '%type: bcash%')}
  scope :pag_seguro, -> { where('params LIKE ?', '%type: pag_seguro%')}
  scope :completed, -> { where('status = ?', 'Completed')}

  private
  def mark_invoicer_as_paid
    if params_valid?
      invoicer.pay
    else
      Airbrake.notify(
        error_class:   "Failed Payment Notification",
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

  def bcash_valid?(hash)
    params[:secret] == hash[:secret]
  end

  def paypal_valid?(hash)
    params[:secret] == hash[:secret] &&
    params[:receiver_email] == hash[:email] &&
    params[:mc_currency] == hash[:currency] &&
    BigDecimal.new(params[:mc_gross].to_s) == BigDecimal.new(invoicer.registration_value.to_s)
  end
end
