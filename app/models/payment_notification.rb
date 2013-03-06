# encoding: UTF-8
class PaymentNotification < ActiveRecord::Base
  belongs_to :invoicer, :class_name => "Attendance"
  serialize :params
  
  validates_existence_of :invoicer

  attr_accessible :params, :invoicer_id, :status, :transaction_id, :notes
  
  after_create :mark_invoicer_as_paid
  
  def self.from_paypal_params(params)
    params.slice(:settle_amount, :settle_currency, :payer_email).merge({
      :params => params,
      :invoicer_id => params[:invoice],
      :status => params[:payment_status],
      :transaction_id => params[:txn_id],
      :notes => params[:memo]
    })
  end
  
  def self.from_bcash_params(params)
    {
      :params => params,
      :invoicer_id => params[:id_pedido],
      :status => params[:cod_status] == 1 ? "Completed" : params[:status],
      :transaction_id => params[:id_transacao],
      :settle_amount => params[:valor_total],
      :settle_currency => "BRL",
      :payer_email => params[:cliente_email]
    }
  end

  private
  def mark_invoicer_as_paid
    if status == "Completed" && params_valid?
      invoicer.confirm
    else
      Airbrake.notify(
        :error_class   => "Failed Payment Notification",
        :error_message => "Failed Payment Notification for invoicer: #{invoicer.inspect}",
        :parameters    => params
      )
    end
  end
  
  def params_valid?
    params[:secret] == AppConfig[:paypal][:secret] &&
    params[:receiver_email] == AppConfig[:paypal][:email] &&
    params[:mc_currency] == AppConfig[:paypal][:currency] &&
    BigDecimal.new(params[:mc_gross].to_s) == BigDecimal.new(invoicer.registration_fee.to_s)
  end
end
