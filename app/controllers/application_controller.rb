# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Net::OpenTimeout, with: :timeout

  around_action :switch_locale

  protect_from_forgery with: :exception

  private

  def not_found
    respond_to do |format|
      format.html { render 'layouts/404', status: :not_found, layout: false }
      format.js { render plain: '404 Not Found', status: :not_found }
      format.csv { render plain: '404 Not Found', status: :not_found }
    end
  end

  def timeout
    respond_to do |format|
      format.html { render 'layouts/408', status: :request_timeout, layout: false }
      format.js { render plain: '408 Request Timeout', status: :request_timeout }
    end
  end

  def switch_locale(&action)
    Rails.logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    locale = extract_locale_from_accept_language_header
    Rails.logger.debug "* Locale set to '#{locale}'"
    I18n.with_locale(locale, &action)
  end

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def assign_event
    @event = Event.find(params[:event_id])
  end
end
