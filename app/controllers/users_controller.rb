# frozen_string_literal: true

class UsersController < ApplicationController
  layout 'eventless'

  def show
    params[:id] ||= current_user.id
    @user = resource
    active_events = @user.attendances.active.map(&:event)
    @events_for_today = Event.active_for(Time.zone.today) - active_events
  end

  def edit
    @user = resource
  end

  def update
    locale = params[:user][:default_locale].to_sym if params[:user][:default_locale]
    I18n.locale = locale if locale.present?

    @user = resource
    if @user.update(update_user_params)
      flash[:notice] = I18n.t('flash.user.update')
      redirect_to @user
    else
      flash[:error] = I18n.t('flash.user.edit')
      render(:edit)
    end
  end

  def index
    @users_list = UserRepository.instance.search_engine(params[:role_index], params[:search])
    respond_to do |format|
      format.js { render 'users/index.js.haml' }
      format.html { render :index }
    end
  end

  def toggle_organizer
    toggle_role('organizer')
    respond_js_to_toggle_roles('users/user')
  end

  def toggle_admin
    toggle_role('admin')
    respond_js_to_toggle_roles('users/user')
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

  private

  def toggle_role(role)
    @user = resource
    if @user.roles.include?(role)
      @user.remove_role(role)
    else
      @user.add_role(role)
    end

    @user.save
  end

  def respond_js_to_toggle_roles(partial)
    respond_to do |format|
      format.js { render partial }
    end
  end
end
