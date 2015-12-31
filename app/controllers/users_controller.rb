# encoding: UTF-8
# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  first_name            :string
#  last_name             :string
#  email                 :string
#  organization          :string
#  phone                 :string
#  country               :string
#  state                 :string
#  city                  :string
#  badge_name            :string
#  cpf                   :string
#  gender                :string
#  twitter_user          :string
#  address               :string
#  neighbourhood         :string
#  zipcode               :string
#  roles_mask            :integer
#  default_locale        :string           default("pt")
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
