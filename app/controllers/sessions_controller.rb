# encoding: UTF-8
class SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authorize_action
  skip_before_action :verify_authenticity_token

  layout 'eventless'

  def new; end

  def create
    auth = Authentication.find_by(provider: auth_hash['provider'], uid: auth_hash['uid'])
    if auth.present?
      log_in_with(auth)
    elsif logged_in?
      flash[:notice] = I18n.t('flash.user.authentication.new')
      add_authentication(auth_hash)
    elsif (user = User.new_from_auth_hash(auth_hash)).save
      flash[:notice] = I18n.t('flash.user.create')
      log_in(user)
      add_authentication(auth_hash)
    else
      flash[:error] = I18n.t('flash.user.invalid') + "#{user.errors.inspect} with #{auth_hash}"
      return redirect_to(login_path)
    end

    origin = request.env['omniauth.origin']
    redirect_to origin == login_url ? current_user : origin
  end

  def resource
    current_user
  end

  def resource_name
    'user'
  end

  helper_method :resource
  helper_method :resource_name

  def failure
    flash[:error] = I18n.t('flash.user.failure')
    redirect_to login_path
  end

  def destroy
    self.current_user = nil
    redirect_to login_path
  end

  protected

  def log_in_with(auth)
    if logged_in? && auth.user != current_user
      flash[:error] = I18n.t('flash.user.authentication.already_in_use')
    else
      log_in(auth.user)
    end
  end

  def add_authentication(auth_hash)
    current_user.authentications.create(
      uid: auth_hash['uid'],
      provider: auth_hash['provider'],
      refresh_token: auth_hash['credentials']['refresh_token']
    )
  end

  def log_in(user)
    self.current_user = user
  end

  def logged_in?
    !current_user.nil?
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end
