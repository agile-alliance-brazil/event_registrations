# encoding: UTF-8
class UsersController < ApplicationController
  layout 'eventless'

  def show
    params[:id] ||= current_user.id
    @user = resource
  end

  def edit
    @user = resource
  end

  def update
    @user = resource
    if @user.update_attributes(update_user_params)
      flash[:notice] = I18n.t('flash.user.update')
      redirect_to @user
    else
      flash[:error] = I18n.t('flash.user.edit')
      render :edit
    end
  end

  private

  def resource
    resource_class.find(params[:id])
  end

  # For our cancan ability check
  def resource_class
    User
  end

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone,
      :country, :state, :city, :organization, :twitter_user, :default_locale)
  end
end
