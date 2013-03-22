# encoding: UTF-8
class PaymentNotification < ActiveRecord::Base
  belongs_to :invoicer, class_name: "Attendance"
  serialize :params
  
  validates_existence_of :invoicer

  attr_accessible :params, :invoicer_id, :status, :transaction_id, :notes
  
  after_create :mark_invoicer_as_paid
  
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

  private
  def mark_invoicer_as_paid
    if status == "Completed" && params_valid?
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
    params[:type] == 'bcash' ? bcash_valid?(AppConfig[:bcash]) : paypal_valid?(AppConfig[:paypal])
  end

  def bcash_valid?(hash)
    params[:secret] == hash[:secret]
  end

  def paypal_valid?(hash)
    params[:secret] == hash[:secret] &&
    params[:receiver_email] == hash[:email] &&
    params[:mc_currency] == hash[:currency] &&
    valid_price?(BigDecimal.new(params[:mc_gross].to_s))
  end

  def valid_price?(paid_price)
     paid_price == BigDecimal.new(invoicer.registration_fee.to_s) ||
       (invoicer.registration_period.super_early_bird? &&
        paid_price == BigDecimal.new(RegistrationPrice.for(invoicer.registration_period, invoicer.registration_type).first.value))
  end
end
