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

class PaymentNotificationsController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :authorize_action
  protect_from_forgery :except => [:create]

  def create
    transaction = PagSeguro::Transaction.find_by_notification_code(params[:notificationCode])

    # p transaction
    transaction_params = params
    transaction_params[:status] = transaction.status.paid? ? 'Completed' : transaction.status.status
    transaction_params[:transaction_code] = transaction.code
    transaction_params[:transaction_inspect] = transaction.inspect
    PaymentNotification.create_for_pag_seguro(transaction_params)
    render :nothing => true
  end
end
