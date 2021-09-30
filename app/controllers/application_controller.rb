# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Net::OpenTimeout, with: :timeout

  before_action :set_locale

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

  def set_locale
    accepted_languages = request.env['HTTP_ACCEPT_LANGUAGE']
    if accepted_languages.blank?
      Rails.logger.info { "* Locale set to '#{I18n.default_locale}'" }
      I18n.locale = I18n.default_locale
    else
      Rails.logger.debug { "* Accept-Language: #{accepted_languages}" }
      locale = extract_locale_from_accept_language_header(accepted_languages)
      Rails.logger.info { "* Locale set to '#{locale}'" }
      I18n.locale = locale
    end
  end

  def extract_locale_from_accept_language_header(env_languages)
    accepted_languages = env_languages.split(',').map { |locale| locale.match('^[^\;]*')[0] }

    return 'pt' if accepted_languages.include?('pt') || accepted_languages.include?('pt-BR')

    'en'
  end

  def assign_event
    @event = Event.find(params[:event_id])
  end
end
