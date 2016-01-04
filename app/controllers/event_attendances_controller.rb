class EventAttendancesController < ApplicationController
  include Concerns::Initiation

  before_action :event

  def new
    @attendance = Attendance.new(event: @event)
  end

  def create
    if !current_user.organizer? && !event.can_add_attendance?
      return redirect_to root_path, flash: { error: t('flash.attendance.create.max_limit_reached') }
    end
    create_params = AttendanceParams.new(current_user, @event, params)
    @attendance = CreateAttendance.run_for create_params
    if @attendance.errors.any?
      flash.now[:error] = t('flash.form.invalid_data')
      return render :new
    end
    redirect_to attendance_path @attendance, notice: t('flash.attendance.create.success')
  end

  def edit
    @attendance = Attendance.find(params[:id])
    @attendance.email_confirmation = @attendance.email
  end

  def update
    update_params = AttendanceParams.new(current_user, @event, params)
    UpdateAttendance.run_for update_params
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

  def to_approval
    @attendances_to_approval = event.attendances.waiting_approval
  end

  def payment_type_report
    @payment_type_report = GeneratePaymentTypeReport.run_for event
  end
end
