# encoding: UTF-8
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery

  before_filter :set_locale
  before_filter :set_timezone
  before_filter :set_event
  before_filter :authenticate_user!

  def authenticate_user!
    
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def current_user= user
    session[:user_id] = user.try(:id)
    @current_user= user
  end

  def set_event
    @event ||= Event.find_by_year(params[:year]) || Event.current
  end

  def default_url_options(options={})
    # Keep locale when navigating links if locale is specified
    params[:locale] ? { :locale => params[:locale] } : {}
  end

  def sanitize(text)
    text.gsub(/[\s;'\"]/,'')
  end

  private
  def set_locale
    I18n.locale = params[:locale] || 'en' || current_user.try(:default_locale)
  end

  def set_timezone
    # current_user.time_zone #=> 'London'
    Time.zone = params[:time_zone]
  end
end
