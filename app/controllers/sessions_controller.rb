# encoding: UTF-8
class SessionsController < ApplicationController
  skip_before_filter :authenticate_user!

  def new
  end

  def backdoor
    user = User.create!(first_name: "Developer", last_name: "Offline")
    log_in(user)
    redirect_to self.current_user
  end
  
  def create
    auth = Authentication.find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid'])
    if auth
      log_in(auth.user)
    else
      if logged_in?
        flash[:notice] = I18n.t('flash.user.authentication.new')
      else
        log_in(create_new_user)
        flash[:notice] = I18n.t('flash.user.create')
      end

      self.current_user.authentications.create(:provider => auth_hash['provider'], :uid => auth_hash['uid'])
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

  def create_new_user
    user = User.new_from_auth_hash(auth_hash)
    user.twitter_user = auth_hash['nickname'] if auth_hash['provider'] == 'twitter'
    user.save!
    user
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end