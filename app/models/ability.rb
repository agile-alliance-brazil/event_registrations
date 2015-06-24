# encoding: UTF-8
class Ability
  include CanCan::Ability

  REGISTRATION_DEADLINE = Time.zone.local(2015, 10, 21, 23, 59, 59)

  def initialize(user, event)
    @user = user || User.new # guest
    @event = event

    alias_action :edit, :update, :destroy, to: :modify

    guest_privileges
    admin_privileges if @user.admin?
    organizer_privileges if @user.organizer?
  end

  private

  def guest_privileges
    can(:read, 'static_pages')
    can(:manage, 'password_resets')
    can(:read, Event)
    can(:manage, @user)

    can([:show, :destroy, :enable_voting, :voting_instructions], Attendance, user_id: @user.id)
    can do |action, subject_class, _subject|
      expand_actions([:create]).include?(action) && [Attendance].include?(subject_class) &&
      Time.zone.now <= @event.end_date
    end
  end

  def admin_privileges
    can(:manage, :all)
  end

  def organizer_privileges
    can(:manage, Attendance)

    can(:manage, 'transfers')
  end
end
