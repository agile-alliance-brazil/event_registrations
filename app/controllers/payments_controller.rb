class PaymentsController < ApplicationController
  skip_before_filter :authenticate_user!, :authorize_action

  before_action :find_event, :find_invoice

  def checkout
    PagSeguro.configure do |config|
      config.token = APP_CONFIG[:pag_seguro][:token]
      config.email = APP_CONFIG[:pag_seguro][:email]
    end

    payment = PagSeguro::PaymentRequest.new
    response = PagSeguroService.checkout(@invoice, payment)

    if response[:errors].present?
      redirect_to event_registration_groups_path(@event), alert: response[:errors]
    else
      @invoice.send_it
      @invoice.save!
      redirect_to response[:url]
    end
  end

  private

  def find_event
    @event = Event.find params[:event_id]
  rescue ActiveRecord::RecordNotFound
    redirect_to events_path, alert: t('event.not_found')
  end

  def find_invoice
    @invoice = Invoice.find params[:id]
  rescue ActiveRecord::RecordNotFound
    redirect_to event_registration_groups_path(@event), alert: t('invoice.not_found')
  end
end