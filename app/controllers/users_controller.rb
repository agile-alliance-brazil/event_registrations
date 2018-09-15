# frozen_string_literal: true

class UsersController < AuthenticatedController
  before_action :assign_user, except: :index
  before_action :check_admin, only: %i[index update_to_organizer update_to_admin]

  def show
    params[:id] ||= current_user.id
    active_events = @user.attendances.active.map(&:event)
    @events_for_today = Event.active_for(Time.zone.today) - active_events
  end

  def edit; end

  def update
    locale = params[:user][:default_locale].to_sym if params[:user][:default_locale]
    I18n.locale = locale if locale.present?

    if @user.update(update_user_params)
      flash[:notice] = I18n.t('users.update.success')
      return redirect_to @user
    end

    render :edit
  end

  def index
    @users_list = UserRepository.instance.search_engine(params[:role_index], params[:search])
    respond_to do |format|
      format.js { render 'users/index.js.haml' }
      format.html { render :index }
    end
  end

  def update_to_organizer
    toggle_role('organizer')
    respond_js_to_toggle_roles('users/user')
  end

  def update_to_admin
    toggle_role('admin')
    respond_js_to_toggle_roles('users/user')
  end

  private

  def assign_user
    @user = User.find(params[:id])
  end

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :country, :state, :city, :organization, :twitter_user, :default_locale)
  end

  def toggle_role(role)
    @user.update(role: role)
  end

  def respond_js_to_toggle_roles(partial)
    respond_to { |format| format.js { render partial } }
  end
end
