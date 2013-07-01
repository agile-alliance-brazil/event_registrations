# encoding: UTF-8
class EventAttendancesController < InheritedResources::Base
  defaults :resource_class => Attendance, :instance_name => "attendance"

  belongs_to :registration_group, :optional => true

  actions :new, :create, :index
  
  before_filter :event
  before_filter :load_registration_types, only: [:new, :create]
  before_filter :validate_free_registration, :only => [:create]

  def index
    index! do |format|
      format.html
      format.csv {
        response.headers['Content-Disposition'] = "attachment; filename=\"#{event.name.parameterize.underscore}.csv\""
      }
    end
  end
  
  def create
    if !current_user.organizer? && !event.can_add_attendance?
      redirect_to root_path, flash: { error: t('flash.attendance.create.max_limit_reached') }
      return
    end

    create! do |success, failure|
      success.html do
        begin
          flash[:notice] = t('flash.attendance.create.success')
          notify(@attendance)
        rescue => ex
          flash[:alert] = t('flash.attendance.mail.fail')
          notify_or_log(ex)
        end
        redirect_to attendance_path(@attendance)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end
  
  private
  def build_resource
    attributes = params[:attendance]
    unless attributes
      attributes = current_user.attendance_attributes
      attributes[:email_confirmation] = current_user.email
      attributes[:gender] = current_user.gender
    end
    attributes[:event_id] = event.id
    attributes[:user_id] = current_user.id
    if parent?
      attributes[:registration_type_id] = event.registration_types.find_by_title('registration_type.group').try(:id)
      attributes[:organization] = parent.name
    end
    if current_user.has_approved_session?(event)
      attributes[:registration_type_id] = event.registration_types.find_by_title('registration_type.speaker').try(:id)
    end
    if @registration_types.size == 1
      attributes[:registration_type_id] = @registration_types.first.id
    end
    attributes[:registration_date] ||= [event.registration_periods.last.end_at, Time.now].min
    @attendance ||= Attendance.new(attributes)
  end

  def collection
    @attendances ||= end_of_association_chain.for_event(event).active.all(include: [:payment_notifications, :event, :registration_type])
  end
  
  def load_registration_types
    @registration_types ||= valid_registration_types
  end

  def valid_registration_types
    registration_types = event.registration_types.paid.without_group.all
    registration_types << event.registration_types.without_group.all if current_user.organizer?
    registration_types.flatten.uniq.compact
  end
    
  def validate_free_registration
    if is_free?(build_resource) && !allowed_free_registration?
      build_resource.errors[:registration_type_id] << t('activerecord.errors.models.attendance.attributes.registration_type_id.free_not_allowed')
      flash.now[:error] = t('flash.attendance.create.free_not_allowed') 
      render :new and return false
    end
    true
  end
  
  def is_free?(attendance)
    !event.registration_types.paid.include?(attendance.registration_type)
  end
  
  def allowed_free_registration?
    (current_user.has_approved_session?(event) || current_user.organizer?) && !parent?
  end

  def event
    @event ||= Event.find_by_id(params[:event_id])
  end

  def notify(attendance)
    if attendance.registration_fee > 0
      EmailNotifications.registration_pending(attendance).deliver
      attendance.email_sent = true
      attendance.save
    end
  end

  def notify_or_log(ex)
    begin
      notify_airbrake(ex)
    rescue
      Rails.logger.error('Airbrake notification failed. Logging error locally only')
      Rails.logger.error(ex.message)
    end
  end
end