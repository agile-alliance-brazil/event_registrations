# encoding: UTF-8
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery

  before_filter :set_locale
  before_filter :set_timezone
  before_filter :set_event

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
    # if params[:locale] is nil then I18n.default_locale will be used
    I18n.locale = params[:locale] || 'en' || current_user.try(:default_locale)
  end

  def set_timezone
    # current_user.time_zone #=> 'London'
    Time.zone = params[:time_zone]
  end
end
