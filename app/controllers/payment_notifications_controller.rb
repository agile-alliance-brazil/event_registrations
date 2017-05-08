class PaymentNotificationsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authorize_action
  protect_from_forgery except: [:create]

  def create
    # rubocop:disable Rails/DynamicFindBy
    transaction = PagSeguro::Transaction.find_by_notification_code(params[:notificationCode])
    if transaction.status.present?
      transaction_params = params
      transaction_params[:status] = transaction.status.try(:paid?) ? 'Completed' : transaction.status.status
      transaction_params[:transaction_code] = transaction.code
      transaction_params[:transaction_inspect] = transaction.inspect
      PaymentNotification.create_for_pag_seguro(transaction_params)
    end
    head :ok
  end
end
