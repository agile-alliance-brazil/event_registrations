# encoding: UTF-8
class Ability
  include CanCan::Ability
  
  REGISTRATION_DEADLINE = Time.zone.local(2013, 6, 22, 23, 59, 59)

  def initialize(user, event)
    @user = user || User.new # guest
    @event = event || Event.current

    alias_action :edit, :update, :destroy, :to => :modify

    guest_privileges
    admin_privileges if @user.admin?
    registrar_privileges if @user.registrar?
  end

  private

  def guest_privileges
    can(:read, 'static_pages')
    can(:manage, 'password_resets')
    can(:show, Attendee)
    can(:show, RegistrationGroup)
    can do |action, subject_class, subject|
      expand_actions([:create, :index, :pre_registered]).include?(action) && [Attendee, RegistrationGroup].include?(subject_class) &&
      Time.zone.now <= REGISTRATION_DEADLINE
    end
    cannot(:index, Attendee)
  end

  def admin_privileges
    can(:manage, :all)
  end

  def registrar_privileges
    can(:manage, 'registered_attendees')
    can(:manage, 'registered_groups')
    can(:manage, 'pending_attendees')
    can(:index, Attendee)
    can(:show, Attendee)
    can(:update, Attendee)
    can do |action, subject_class, subject|
      expand_actions([:create, :index, :pre_registered]).include?(action) && [Attendee, RegistrationGroup].include?(subject_class)
    end
  end
end
