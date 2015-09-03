# encoding: UTF-8
class EventAttendancesController < ApplicationController
  include Concerns::Initiation
  include Concerns::Groupable

  before_filter :event
  before_filter :load_registration_types, only: [:new, :create]

  def new
    @attendance = Attendance.new(build_attributes)
  end

  def create
    if !current_user.organizer? && !event.can_add_attendance?
      redirect_to root_path, flash: { error: t('flash.attendance.create.max_limit_reached') }
      return
    end
    attributes = build_attributes
    attendance = @event.attendances.find_by(email: attendance_params[:email], status: [:pending, :accepted, :paid, :confirmed])
    return redirect_to(attendance_path(attendance), notice: I18n.t('flash.attendance.create.already_existent')) if attendance.present?
    @attendance = Attendance.new(attributes)
    perform_group_check!
    put_band
    @attendance.registration_value = @event.registration_price_for(@attendance, payment_type_params)
    save_attendance!
  end

  def edit
    @attendance = Attendance.find(params[:id])
    @attendance.email_confirmation = @attendance.email
    @registration_token = @attendance.registration_group.token if @attendance.registration_group
    @payment_type = @attendance.payment_type
  end

  def update
    @attendance = Attendance.find(params[:id])
    @attendance.update_attributes!(attendance_params)
    perform_group_check!
    @attendance.registration_value = @event.registration_price_for(@attendance, payment_type_params)
    @attendance.save!

    invoice = @attendance.invoices.individual.last
    invoice.payment_type = payment_type_params
    invoice.save!
    redirect_to attendances_path(event_id: @event)
  end

  def by_state
    @attendances_state_grouped = event.attendances.active.group(:state).order('count_id desc').count('id')
  end

  def by_city
    @attendances_city_grouped = event.attendances.active.group(:city, :state).order('count_id desc').count('id')
  end

  def last_biweekly_active
    @attendances_biweekly_grouped = event.attendances.last_biweekly_active.group('date(created_at)').count(:id)
  end

  private

  def save_attendance!
    invoice = Invoice.from_attendance(@attendance, payment_type_params)
    @attendance.invoices << invoice unless @attendance.invoices.include? invoice
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

  def put_band
    @attendance.registration_period = @event.period_for
    quota = @event.find_quota
    @attendance.registration_quota = quota.first if quota.present?
  end

  def attendance_params
    params[:attendance].nil? ? nil : params.require(:attendance).permit(
      :event_id, :user_id, :registration_type_id, :registration_group_id, :registration_date, :first_name, :last_name, :email,
      :email_confirmation, :organization, :phone, :country, :state, :city, :badge_name, :cpf, :gender, :twitter_user, :address, :neighbourhood, :zipcode, :notes)
  end

  def valid_registration_types
    registration_types = event.registration_types.paid.without_group.to_a
    registration_types += event.registration_types.without_group.to_a if current_user.organizer?
    registration_types.flatten.uniq.compact
  end

  def notify(attendance)
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

  def payment_type_params
    params['payment_type'] || Invoice::GATEWAY
  end
end
