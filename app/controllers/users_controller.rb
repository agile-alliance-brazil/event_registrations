# encoding: UTF-8
# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  first_name            :string(255)
#  last_name             :string(255)
#  email                 :string(255)
#  organization          :string(255)
#  phone                 :string(255)
#  country               :string(255)
#  state                 :string(255)
#  city                  :string(255)
#  badge_name            :string(255)
#  cpf                   :string(255)
#  gender                :string(255)
#  twitter_user          :string(255)
#  address               :string(255)
#  neighbourhood         :string(255)
#  zipcode               :string(255)
#  roles_mask            :integer
#  default_locale        :string(255)      default("pt")
#  created_at            :datetime
#  updated_at            :datetime
#  registration_group_id :integer
#

class UsersController < ApplicationController
  layout 'eventless'

  def show
    params[:id] ||= current_user.id
    @user = resource
    @events_for_today = Event.active_for Time.zone.today
  end

  def edit
    @user = resource
  end

  def update
    locale = params[:user][:default_locale].to_sym if params[:user][:default_locale]
    I18n.locale = locale if locale

    @user = resource
    if @user.update_attributes(update_user_params)
      flash[:notice] = I18n.t('flash.user.update')
      redirect_to @user
    else
      flash[:error] = I18n.t('flash.user.edit')
      render(:edit)
    end
  end

  def resource
    resource_class.find(params[:id])
  end

  # For our cancan ability check
  def resource_class
    User
  end

  protected

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone,
      :country, :state, :city, :organization, :twitter_user, :default_locale)
  end
end
