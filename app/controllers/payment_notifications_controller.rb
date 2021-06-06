# frozen_string_literal: true

class PaymentNotificationsController < ApplicationController
  protect_from_forgery prepend: true, with: :exception, except: [:create]

  # rubocop disabled due to gem implementation out of the pattern
  # rubocop:disable Rails/DynamicFindBy
  def create
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
  # rubocop:enable Rails/DynamicFindBy
end
