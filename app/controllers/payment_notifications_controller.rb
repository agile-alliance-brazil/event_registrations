# == Schema Information
#
# Table name: payment_notifications
#
#  id              :integer          not null, primary key
#  params          :text(65535)
#  status          :string(255)
#  transaction_id  :string(255)
#  payer_email     :string(255)
#  settle_amount   :decimal(10, )
#  settle_currency :string(255)
#  notes           :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#  invoice_id      :integer
#
# Indexes
#
#  fk_rails_92030b1506  (invoice_id)
#

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
    render nothing: true
  end
end
