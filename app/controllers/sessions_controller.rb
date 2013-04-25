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
      if logged_in? && auth.user != current_user
        flash[:error] = I18n.t('flash.user.authentication.already_in_use')
      else
        log_in(auth.user)
      end
    elsif logged_in?
      flash[:notice] = I18n.t('flash.user.authentication.new')
      self.current_user.authentications.create(:provider => auth_hash['provider'], :uid => auth_hash['uid'], :refresh_token => auth_hash['credentials']['refresh_token'])
    else
      user = User.new_from_auth_hash(auth_hash)
      if user.save
        log_in(user)
        flash[:notice] = I18n.t('flash.user.create')
        self.current_user.authentications.create(:provider => auth_hash['provider'], :uid => auth_hash['uid'], :refresh_token => auth_hash['credentials']['refresh_token'])
      else
        flash[:error] = I18n.t('flash.user.invalid')
        redirect_to(login_path) and return
      end
    end

    origin = request.env['omniauth.origin']
    redirect_to (origin == login_url ? self.current_user : origin)
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