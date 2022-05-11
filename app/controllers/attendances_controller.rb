# frozen_string_literal: true

class AttendancesController < AuthenticatedController
  before_action :assign_event
  before_action :assign_attendance, except: %i[index create new search user_info]

  before_action :check_organizer, only: %i[index search user_info]
  before_action :check_user, only: %i[show edit update]
  before_action :check_event, only: %i[new create]

  before_action :assign_last_attendance_for_user, only: %i[new create edit update]

  def new
    @attendance = Attendance.new(event: @event)
  end

  def create
    user_for_attendance = User.find(user_id)
    @attendance = user_for_attendance.attendances.where(event: @event).not_cancelled.first

    if @attendance.present?
      flash[:alert] = I18n.t('attendances.create.already_existent')

      return render :new
    end

    create_params = AttendanceParams.new(current_user, @event, params)
    @attendance = CreateAttendance.run_for(create_params)
    return redirect_to(event_attendance_path(@event, @attendance), flash: { notice: I18n.t('attendances.create.success') }) if @attendance.valid?

    flash[:error] = @attendance.errors.full_messages.join(' | ')
    render :new
  end

  def edit; end

  def update
    update_params = AttendanceParams.new(current_user, @event, params)
    @attendance = UpdateAttendance.run_for(update_params)
    return redirect_to event_attendances_path(event_id: @event, flash: { notice: I18n.t('attendances.update.success') }) if @attendance.valid?

    flash[:error] = @attendance.errors.full_messages.join(' | ')
    render :edit
  end

  def index
    @attendances_list = @event.attendances.active.order(updated_at: :desc)
    @attendances_list_csv = AttendanceExportService.to_csv(@attendances_list)
    @waiting_total = @event.attendances.waiting.count
    @pending_total = @event.attendances.pending.count
    @accepted_total = @event.attendances.accepted.count
    @paid_total = @event.attendances.paid.count
    @reserved_total = @event.reserved_count
    @accredited_total = @event.attendances.showed_in.count
    @confirmed_total = @event.attendances.confirmed.count
    @cancelled_total = @event.attendances.cancelled.count
    @total = @event.attendances_count
  end

  def show; end

  def destroy
    @attendance.cancelled!
    respond_to do |format|
      format.js { return render 'attendances/attendance' }
      format.html { redirect_to event_attendance_path(@event, @attendance), flash: { notice: I18n.t('attendance.destroy.success') } }
    end
  end

  def change_status
    case params[:new_status]
    when 'accept'
      @attendance.accepted!
      EmailNotificationsMailer.registration_group_accepted(@attendance).deliver
    when 'pay'
      @attendance.paid!
      EmailNotificationsMailer.registration_paid(@attendance).deliver
    when 'confirm'
      @attendance.confirmed!
      EmailNotificationsMailer.registration_confirmed(@attendance).deliver
    when 'mark_show'
      @attendance.showed_in!
    else
      @attendance.pending!
    end

    respond_to do |format|
      format.js { render 'attendances/attendance' }
      format.html { redirect_to event_attendance_path(@event, @attendance) }
    end
  end

  def search
    @attendances_list = AttendanceRepository.instance.search_for_list(@event, params[:search], params[:user_disability], statuses_params).order(updated_at: :desc)
    @attendances_list_csv = AttendanceExportService.to_csv(@attendances_list)

    respond_to { |format| format.js { render 'attendances/search' } }
  end

  def user_info
    @user = User.where(id: params[:user_id]).first_or_initialize
    @attendance = Attendance.new(user: @user)
    respond_to { |format| format.js { render 'attendances/user_info' } }
  end

  private

  def assign_last_attendance_for_user
    @user_last_attendance = current_user.attendances.not_cancelled.order(registration_date: :asc).last
  end

  def user_id
    @user_id ||= params[:attendance][:user_id] || current_user.id
  end

  def assign_attendance
    @attendance = Attendance.find(params[:id])
  end

  def statuses_params
    params.select { |_key, value| value == 'true' }.keys
  end

  def check_user
    return if current_user.organizer_of?(@event)

    not_found if current_user.id != @attendance.user.id
  end

  def check_event
    not_found if @event.ended?
  end
end
