# encoding: UTF-8
class SessionsController < ApplicationController
  def new
  end
  
  def create
    auth = Authentication.find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid'])
    if auth
      self.current_user = auth.user
    else
      if self.current_user.nil?
        user = User.new_from_auth_hash(auth_hash)
        user.twitter_user = auth_hash[:nickname] if auth.provider == 'twitter'
        user.save!
        self.current_user = user
        flash[:notice] = I18n.t('flash.user.create')
      else
        flash[:notice] = I18n.t('flash.user.authentication.new')
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

  def auth_hash
    request.env['omniauth.auth']
  end
end