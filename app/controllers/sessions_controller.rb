# encoding: UTF-8
class SessionsController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :authorize_action

  layout 'eventless'

  def new
  end
  
  def create
    auth = Authentication.find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid'])
    if auth
      log_in(auth.user)
    elsif logged_in?
      flash[:notice] = I18n.t('flash.user.authentication.new')
      self.current_user.authentications.create(:provider => auth_hash['provider'], :uid => auth_hash['uid'])
    else
      user = User.new_from_auth_hash(auth_hash)
      if user.save
        log_in(user)
        flash[:notice] = I18n.t('flash.user.create')
        self.current_user.authentications.create(:provider => auth_hash['provider'], :uid => auth_hash['uid'])
      else
        flash[:notice] = I18n.t('flash.user.invalid')
        redirect_to(login_path) and return
      end
    end

    redirect_to self.current_user
  end

  def resource
    self.current_user
  end

  def resource_name
    "user"
  end

  helper_method :resource
  helper_method :resource_name

  def failure
    flash[:error] = I18n.t('flash.user.failure')
    redirect_to login_path
  end

  def destroy
    self.current_user= nil
    redirect_to login_path
  end

  protected
  def log_in(user)
    self.current_user = user
  end

  def logged_in?
    !self.current_user.nil?
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end