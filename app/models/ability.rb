# frozen_string_literal: true

class Ability
  include CanCan::Ability

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
    can(%i[new create], AttendancesController)
    can(%i[edit update], AttendancesController) { |attendance| attendance.user_id == @user.id || attendance.email == @user.email }

    can(:manage, @user)
    can(%i[show destroy], Attendance) { |attendance| attendance.user_id == @user.id || attendance.email == @user.email }

    can do |action, subject_class, _subject|
      expand_actions([:create]).include?(action) && [Attendance].include?(subject_class) && Time.zone.now <= @event.end_date
    end
  end

  def admin_privileges
    can(:manage, :all)
  end

  def organizer_privileges
    can(%i[show edit update], Event) { |event| @user.organized_events.include?(event) }
    can(%i[show edit update], EventsController) { |event| @user.organized_events.include?(event) }
    can(:read, ReportsController) if @user.organized_events.include?(@event)
    can(:waiting_list, Attendance) if @user.organized_events.include?(@event)
    can(:show, User) { |user| @user.organized_user_present?(user) }
    can(:manage, AttendancesController) if @user.organized_events.include?(@event)
    can(:manage, TransfersController) if @user.organized_events.include?(@event)
    can(:manage, Attendance) if @user.organized_events.include?(@event)
    can(:manage, RegistrationPeriod) { |period| @user.organized_events.include?(period.event) }
    can(:manage, RegistrationQuota) { |quota| @user.organized_events.include?(quota.event) }
    can(:manage, RegistrationGroup) { |group| @user.organized_events.include?(group.event) }
  end
end
