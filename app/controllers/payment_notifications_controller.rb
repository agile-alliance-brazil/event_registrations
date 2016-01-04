# encoding: UTF-8
class PaymentNotificationsController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :authorize_action
  protect_from_forgery :except => [:create]

  def create
    transaction = PagSeguro::Transaction.find_by_notification_code(params[:notificationCode])
    transaction_params = params
    transaction_params[:status] = transaction.status.paid? ? 'Completed' : transaction.status.status
    transaction_params[:transaction_code] = transaction.code
    transaction_params[:transaction_inspect] = transaction.inspect
    PaymentNotification.create_for_pag_seguro(transaction_params)
    render :nothing => true
  end
end
