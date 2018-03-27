# frozen_string_literal: true

class UserAbility
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new # guest

    alias_action :edit, :update, :destroy, to: :modify

    guest_privileges
    admin_privileges if @user.admin?
  end

  private

  def guest_privileges
    can(:manage, @user)
    can(%i[show edit update], UsersController) { |user| user.id = @user.id }
    can(%i[show destroy], Attendance) { |attendance| attendance.user_id == @user.id || attendance.email == @user.email }
  end

  def admin_privileges
    can(:manage, :all)
  end
end
