class EventAttendancesController < ApplicationController
  rescue_from Net::OpenTimeout, with: :timeout

  before_action :event
  before_action :check_group, only: [:create]

  def new
    @attendance = Attendance.new(event: @event)
  end

  def create
    create_params = AttendanceParams.new(current_user, @event, params)
    @attendance = CreateAttendance.run_for(create_params)
    return render :new if @attendance.errors.any?
    redirect_to attendance_path @attendance, notice: t('flash.attendance.create.success')
  end

  def edit
    @attendance = Attendance.find(params[:id])
  end

  def update
    update_params = AttendanceParams.new(current_user, @event, params)
    UpdateAttendance.run_for(update_params)
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
      format.html { render file: Rails.root.join('public', '408'), layout: false, status: 408 }
      format.js { render plain: '408 Request Timeout', status: 408 }
    end
  end

  def check_group
    group = RegistrationGroup.find_by(token: params[:registration_token])
    return if group.blank? || group.vacancies?
    @attendance = Attendance.new(attendance_params)
    flash[:error] = I18n.t('attendances.create.errors.group_full', group_name: group.name)
    render :new
  end

  def attendance_params
    params.require(:attendance).permit(
      :payment_type, :event_id, :user_id, :registration_group_id, :registration_date, :first_name, :last_name, :email,
      :organization, :organization_size, :job_role, :years_of_experience, :experience_in_agility,
      :school, :education_level, :phone, :country, :state, :city, :badge_name, :cpf, :gender
    )
  end
end
