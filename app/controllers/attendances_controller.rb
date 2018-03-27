# frozen_string_literal: true

class AttendancesController < ApplicationController
  rescue_from Net::OpenTimeout, with: :timeout

  before_action :assign_event
  before_action :assign_attendance, except: %i[index create new waiting_list search to_approval]

  def new
    @attendance = Attendance.new(event: @event)
  end

  def create
    create_params = AttendanceParams.new(current_user, @event, params)
    @attendance = CreateAttendance.run_for(create_params)
    return render :new unless @attendance.valid?
    redirect_to event_attendance_path(@event, @attendance)
    flash[:notice] = t('flash.attendance.create.success')
  end

  def edit; end

  def update
    update_params = AttendanceParams.new(current_user, @event, params)
    UpdateAttendance.run_for(update_params)
    redirect_to event_attendances_path(event_id: @event)
  end

  def to_approval
    @attendances_to_approval = @event.attendances.waiting_approval
  end

  def waiting_list
    @waiting_list = @event.attendances.waiting
  end

  def index
    @attendances_list = @event.attendances.active.order(last_status_change_date: :desc)
    @waiting_total = @event.attendances.waiting.count
    @pending_total = @event.attendances.pending.count
    @accepted_total = @event.attendances.accepted.count
    @paid_total = @event.attendances.paid.count
    @reserved_total = @event.reserved_count
    @accredited_total = @event.attendances.showed_in.count
    @cancelled_total = @event.attendances.cancelled.count
    @total = @event.attendances_count
    @burnup_registrations_data = ReportService.instance.create_burnup_structure(@event)
  end

  def show
    @invoice = Invoice.for_attendance(@attendance.id).first
    respond_to do |format|
      format.html
      format.json
    end
  end

  def destroy
    @attendance.cancel
    redirect_to event_attendance_path(@event, @attendance)
  end

  def change_status
    @attendance.send(params[:new_status])
    redirect_to event_attendances_path(@event)
  end

  def search
    @attendances_list = AttendanceRepository.instance.search_for_list(@event, params[:search], statuses_params)

    respond_to do |format|
      format.js {}
      format.csv do
        send_data AttendanceExportService.to_csv(@event), filename: 'attendances_list.csv'
      end
    end
  end

  private

  def assign_event
    @event = Event.find(params[:event_id])
  end

  def assign_attendance
    @attendance = Attendance.find(params[:id])
  end

  def timeout
    respond_to do |format|
      format.html { render file: Rails.root.join('public', '408'), layout: false, status: 408 }
      format.js { render plain: '408 Request Timeout', status: :request_timeout }
    end
  end

  def statuses_params
    statuses = []
    statuses << :pending if params[:pending] == 'true'
    statuses << :accepted if params[:accepted] == 'true'
    statuses += %i[paid confirmed] if params[:paid] == 'true'
    statuses << :cancelled if params[:cancelled] == 'true'
    statuses << :showed_in if params[:showed_in] == 'true'
    statuses
  end
end
