# encoding: UTF-8
class PaymentNotification < ActiveRecord::Base
  belongs_to :invoicer, class_name: 'Attendance', foreign_key: 'invoicer_id'
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

  scope :paypal, -> { where('params LIKE ?', '%type: paypal%')}
  scope :bcash, -> { where('params LIKE ?', '%type: bcash%')}
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
    params[:type] == 'bcash' ? bcash_valid?(APP_CONFIG[:bcash]) : paypal_valid?(APP_CONFIG[:paypal])
  end

  def bcash_valid?(hash)
    params[:secret] == hash[:secret]
  end

  def paypal_valid?(hash)
    params[:secret] == hash[:secret] &&
    params[:receiver_email] == hash[:email] &&
    params[:mc_currency] == hash[:currency] &&
    BigDecimal.new(params[:mc_gross].to_s) == BigDecimal.new(invoicer.registration_fee.to_s)
  end
end
