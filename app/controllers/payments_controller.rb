# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :assign_event
  before_action :assign_attendance

  def checkout
    PagSeguroService.config
    payment = PagSeguro::PaymentRequest.new
    payment.notification_url = notification_url
    payment.redirect_url = back_url
    response = PagSeguroService.checkout(@attendance, payment)

    if response[:errors].present?
      pagseguro_errors_array = response[:errors].split(/\\n/)
      error_message = "#{pagseguro_errors_array.shift}<ul>#{pagseguro_errors_array.map { |pagseguro_error| "<li>#{pagseguro_error}</li>" if pagseguro_error }.flatten.join('')}</ul>"
      flash[:error] = I18n.t('payments_controller.checkout.error', reason: error_message)
      redirect_to event_attendance_path(@event, @attendance)
    else
      flash[:notice] = I18n.t('payments_controller.checkout.success')
      redirect_to response[:url]
    end
  end

  private

  def back_url
    request.referer || root_path
  end

  def notification_url
    payment_notifications_url(
      type: 'pag_seguro',
      pedido: @attendance.id,
      store_code: APP_CONFIG[:pag_seguro][:store_code]
    )
  end

  def assign_attendance
    @attendance = Attendance.find(params[:id])
  end
end
