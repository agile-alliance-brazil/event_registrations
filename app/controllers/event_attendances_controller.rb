class EventAttendancesController < ApplicationController
  rescue_from Net::OpenTimeout, with: :timeout

  before_action :event

  def new
    @attendance = Attendance.new(event: @event)
  end

  def create
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

  def waiting_list
    @waiting_list = event.attendances.waiting
  end

  private

  def resource_class
    Attendance
  end

  def resource
    Attendance.find_by(id: params[:id])
  end

  def event
    @event ||= Event.includes(registration_periods: [:event]).find_by(id: params.require(:event_id))
  end

  def timeout
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/408", layout: false, status: 408 }
      format.js { render plain: '408 Request Timeout', status: 408 }
    end
  end
end
