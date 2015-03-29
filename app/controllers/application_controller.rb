# encoding: UTF-8
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery

  before_filter :set_locale
  before_filter :set_timezone
  before_filter :authenticate_user!
  before_filter :authorize_action

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"

    flash[:error] = t('flash.unauthorised')
    redirect_to :back rescue redirect_to root_path
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

  def current_user= user
    session[:user_id] = user.try(:id)
    Rails.logger.info "Saving session id as #{session[:user_id]}"
    @current_user = user
  end

  def default_url_options(options = {})
    # Keep locale when navigating links if locale is specified
    params[:locale] ? { :locale => params[:locale] } : {}
  end

  def sanitize(text)
    text.gsub(/[\s;'\"]/, '')
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
    @event ||= Event.find_by_id(params[:event_id])
  end

  def authorize_action
    obj = resource rescue nil
    clazz = resource_class rescue nil
    action = params[:action].to_sym
    controller = obj || clazz || controller_name
    authorize!(action, controller)
  end
end
