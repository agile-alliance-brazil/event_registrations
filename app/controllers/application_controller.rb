# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from AWS::SES::ResponseError, with: :no_verified_receiver
  rescue_from Net::OpenTimeout, with: :timeout

  protect_from_forgery with: :exception

  private

  def not_found
    respond_to do |format|
      format.html { render 'layouts/404', status: :not_found, layout: false }
      format.js { render plain: '404 Not Found', status: :not_found }
      format.csv { render plain: '404 Not Found', status: :not_found }
    end
  end

  def no_verified_receiver
    Airbrake.notify('MessageRejected - Email address is not verified. The following identities failed the check in region US-EAST-1', params)
  end

  def timeout
    respond_to do |format|
      format.html { render 'layouts/408', status: :request_timeout, layout: false }
      format.js { render plain: '408 Request Timeout', status: :request_timeout }
    end
  end

  def assign_event
    @event = Event.find(params[:event_id])
  end
end
