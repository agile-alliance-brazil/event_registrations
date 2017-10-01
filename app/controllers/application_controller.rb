class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  helper :all
  protect_from_forgery with: :exception

  before_action :set_locale
  before_action :set_timezone
  before_action :authenticate_user!
  before_action :authorize_action

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"

    flash[:error] = t('flash.unauthorised')
    redirect_back(fallback_location: root_path)
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, event)
  end

  def authenticate_user!
    redirect_to login_path unless current_user
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @current_user
  end
  helper_method :current_user

  def current_user=(user)
    session[:user_id] = user.try(:id)
    Rails.logger.info "Saving session id as #{session[:user_id]}"
    @current_user = user
  end

  def default_url_options(options = {})
    # Keep locale when navigating links if locale is specified
    locale_options = params[:locale] ? { locale: params[:locale] } : {}
    options.merge(locale_options)
  end

  def not_found
    respond_to do |format|
      format.html { render file: Rails.root.join('public', '404'), layout: false, status: 404 }
      format.js   { render plain: '404 Not Found', status: 404 }
    end
  end

  private

  def set_locale
    I18n.locale = params[:locale] || current_user.try(:default_locale)
  end

  def set_timezone
    # current_user.time_zone #=> 'London'
    Time.zone = params[:time_zone]
  end

  def event
    @event ||= Event.find_by(id: params[:event_id])
  end

  def find_event
    @event = Event.find params[:event_id]
  end

  def authorize_action
    obj = call_or_nil(:resource)
    clazz = call_or_nil(:resource_class)
    action = params[:action].to_sym
    controller = obj || clazz || controller_name
    authorize!(action, controller)
  end

  def call_or_nil(method)
    send(method)
  rescue StandardError
    nil
  end
end
