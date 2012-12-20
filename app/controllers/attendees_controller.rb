# encoding: UTF-8
class AttendeesController < InheritedResources::Base
  belongs_to :registration_group, :optional => true

  actions :index, :new, :create
  
  before_filter :validate_total_attendees, :only => [:new, :create]
  before_filter :load_registration_types, :only => [:new, :create]
  before_filter :validate_free_registration, :only => [:create]

  def index
    if current_user.present? && (current_user.admin? || current_user.registrar?)
      @attendees = Attendee.all
      @course_attendances = CourseAttendance.all
      index!
    else
      redirect_to new_attendee_path
    end
  end
  
  def new
    flash.now[:news] = t('flash.attendee.news').html_safe unless parent?
    new!
  end
  
  def create
    create! do |success, failure|
      success.html do
        begin
          if parent?
            EmailNotifications.registration_group_attendee(@attendee, parent).deliver
            @attendee.email_sent = true
            @attendee.save
            if parent.complete
              flash[:notice] = t('flash.attendee.create.success')
              EmailNotifications.registration_group_pending(parent).deliver
              parent.email_sent = true
              parent.save
              redirect_to root_path
            else
              flash[:notice] = t('flash.attendee.registration_group.success')
              redirect_to new_registration_group_attendee_path(parent)
            end
          else
            flash[:notice] = t('flash.attendee.create.success')
            EmailNotifications.registration_pending(@attendee).deliver if @attendee.registration_fee > 0
            @attendee.email_sent = true
            @attendee.save
            redirect_to root_path
          end
        rescue => ex
          notify_airbrake(ex)
          flash[:alert] = t('flash.attendee.mail.fail')
          redirect_to root_path
        end
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end
  
  def pre_registered
    pre_registration = PreRegistration.registered(params[:email]).first
    pre_registered = (not pre_registration.nil?) && (not pre_registration.used?)
    respond_to do |format|
      format.js { render :js => pre_registered.to_s }
    end
  end
  
  private
  def build_resource
    attributes = params[:attendee]
    if(allowed_free_registration? && !current_user.registrar?)
      attributes ||= current_user.attributes
    else
      attributes ||= {}
    end
    attributes[:event_id] = @event.id
    attributes[:default_locale] ||= I18n.locale
    if parent?
      attributes[:registration_type_id] = RegistrationType.find_by_title('registration_type.group').id
      attributes[:organization] = parent.name
    end
    if current_user.present? && current_user.has_approved_session?(@event)
      attributes[:registration_type_id] = RegistrationType.find_by_title('registration_type.free').id
    end
    attributes.select!{ |key, value| Attendee.new.send(:_accessible_attributes)[:default].include?(key) }
    @attendee ||= end_of_association_chain.send(method_for_build, attributes)
  end
  
  def load_registration_types
    if @registration_types.blank?
      @registration_types = parent? ? RegistrationType.without_free.all : RegistrationType.without_free.without_group.all
      @registration_types << RegistrationType.find_by_title('registration_type.free') if allowed_free_registration?
    end
  end
  
  def validate_total_attendees
    if parent? && parent.complete?
      flash[:error] = t('flash.attendee.registration_group.complete', :total_attendees => parent.total_attendees)
      redirect_to root_path
    end
  end
  
  def validate_free_registration
    if !is_free?(build_resource)
      return true
    elsif !allowed_free_registration?
      build_resource.errors[:registration_type_id] << t('activerecord.errors.models.attendee.attributes.registration_type_id.free_not_allowed')
      flash.now[:error] = t('flash.attendee.create.free_not_allowed') 
      render :new and return false
    elsif !current_user.registrar? && build_resource.email != current_user.email
      build_resource.errors[:email] << t('activerecord.errors.models.attendee.attributes.email.free_not_allowed')
      flash.now[:error] = t('flash.attendee.create.free_not_allowed')
      render :new and return false
    end
  end
  
  def is_free?(attendee)
    attendee.registration_type == RegistrationType.find_by_title('registration_type.free')
  end
  
  def allowed_free_registration?
    current_user.present? && (current_user.has_approved_session?(@event) || current_user.registrar?) && !parent?
  end
end
