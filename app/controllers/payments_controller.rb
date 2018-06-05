# frozen_string_literal: true

class PaymentsController < ApplicationController
  skip_before_action :authenticate_user!, :authorize_action

  before_action :assign_event
  before_action :assign_attendance

  def checkout
    PagSeguroService.config
    payment = PagSeguro::PaymentRequest.new
    payment.notification_url = notification_url
    payment.redirect_url = back_url
    response = PagSeguroService.checkout(@attendance, payment)

    if response[:errors].present?
      flash[:error] = I18n.t('payments_controller.checkout.error', reason: response[:errors])
      redirect_to event_registration_groups_path(@event)
    else
      flash[:notice] = I18n.t('payments_controller.checkout.success')
      redirect_to response[:url]
    end
  end

  private

  def assign_event
    @event = Event.find(params[:event_id])
  end

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
