# frozen_string_literal: true

class UsersController < AuthenticatedController
  before_action :assign_user, except: %i[index search_users search_users]
  before_action :check_admin, only: %i[index update_to_organizer update_to_admin]
  before_action :check_user, only: %i[show edit update]
  skip_before_action :authenticate_user!, only: %i[edit_default_password update_default_password]

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
      return redirect_to user_path(@user)
    end

    render :edit
  end

  def index
    @users_list = UserRepository.instance.search_engine(params[:role_index], params[:search])
  end

  def update_to_organizer
    @user.toggle_organizer
    redirect_to users_path
  end

  def update_to_admin
    @user.toggle_admin
    redirect_to users_path
  end

  def edit_default_password; end

  def update_default_password
    @user.password = update_default_password_params[:password]
    @user.password_confirmation = update_default_password_params[:update_default_password_params]

    if @user.valid?
      @user.save
      sign_in @user
      redirect_to root_path, notice: I18n.t('users.completed_login.success')
    else
      flash[:error] = @user.errors.full_messages.join(', ')
      render :edit_default_password
    end
  end

  def search_users
    @users_list = UserRepository.instance.search_engine(params[:roles], params[:search])
    respond_to { |format| format.js { render file: 'users/search_users' } }
  end

  private

  def assign_user
    @user = User.find(params[:id])
  end

  def update_user_params
    params.require(:user).permit(:user_image, :first_name, :last_name, :email, :phone, :country, :state, :city, :organization, :twitter_user, :default_locale)
  end

  def update_default_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def check_user
    return if current_user.admin?
    not_found if current_user.id != @user.id
  end
end
