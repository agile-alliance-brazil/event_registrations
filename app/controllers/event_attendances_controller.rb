# encoding: UTF-8
class EventAttendancesController < ApplicationController
  before_filter :event
  before_filter :load_registration_types, only: [:new, :create]

  def index
    @attendances = Attendance.for_event(event).active.includes(:payment_notifications, :event, :registration_type).all
    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename=\"#{event.name.parameterize.underscore}.csv\""
      end
    end
  end

  def new
    @attendance = Attendance.new(build_attributes)
  end

  def create
    if !current_user.organizer? && !event.can_add_attendance?
      redirect_to root_path, flash: { error: t('flash.attendance.create.max_limit_reached') }
      return
    end
    attributes = build_attributes
    @attendance = Attendance.new(attributes)

    group = @event.registration_groups.find_by_token(params['registration_token'])
    @attendance.registration_group = group if group.present? && group.accept_members?

    return unless validate_free_registration(@attendance)
    @attendance.registration_value = @event.registration_price_for(@attendance)
    save_attendance!
  end

  private

  def save_attendance!
    if @attendance.save
      begin
        flash[:notice] = t('flash.attendance.create.success')
        notify(@attendance)
      rescue => ex
        flash[:alert] = t('flash.attendance.mail.fail')
        notify_or_log(ex)
      end
      redirect_to attendance_path(@attendance)
    else
      flash.now[:error] = t('flash.failure')
      render :new
    end
  end

  private

  def resource
    Attendance.find_by_id(params[:id])
  end

  def resource_class
    Attendance
  end

  def build_attributes
    attributes = attendance_params || {}
    attributes = current_user.attendance_attributes.merge(attributes)
    attributes[:email_confirmation] ||= current_user.email
    attributes[:event_id] = event.id
    attributes[:user_id] = current_user.id
    if @registration_types.size == 1
      attributes[:registration_type_id] = @registration_types.first.id
    end
    attributes[:registration_date] ||= [event.registration_periods.last.end_at, Time.zone.now].min
    attributes
  end

  def attendance_params
    params[:attendance].nil? ? nil : params.require(:attendance).permit(:event_id, :user_id, :registration_type_id,
                                                                        :registration_group_id, :registration_date, :first_name, :last_name, :email,
                                                                        :email_confirmation, :organization, :phone, :country, :state, :city,
                                                                        :badge_name, :cpf, :gender, :twitter_user, :address, :neighbourhood,
                                                                        :zipcode, :notes)
  end

  def load_registration_types
    @registration_types ||= valid_registration_types
  end

  def valid_registration_types
    registration_types = event.registration_types.paid.without_group.to_a
    registration_types += event.registration_types.without_group.to_a if current_user.organizer?
    registration_types.flatten.uniq.compact
  end

  def validate_free_registration(attendance)
    if @event.free?(attendance) && !current_user.allowed_free_registration?
      attendance.errors[:registration_type_id] << t('activerecord.errors.models.attendance.attributes.registration_type_id.free_not_allowed')
      flash.now[:error] = t('flash.attendance.create.free_not_allowed')
      render :new and return false
    end
    true
  end

  def event
    @event ||= Event.includes(registration_types: [:event], registration_periods: [:event]).find_by_id(params.require(:event_id))
  end

  def notify(attendance)
    return unless attendance.registration_fee > 0
    EmailNotifications.registration_pending(attendance).deliver
    attendance.email_sent = true
    attendance.save
  end

  def notify_or_log(ex)
    notify_airbrake(ex)
  rescue
    Rails.logger.error('Airbrake notification failed. Logging error locally only')
    Rails.logger.error(ex.message)
  end
end
