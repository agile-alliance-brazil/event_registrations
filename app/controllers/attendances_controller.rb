class AttendancesController < ApplicationController
  before_action :load_event, except: [:index, :search]
  protect_from_forgery

  def index
    @attendances_list = event_for_index.attendances.active
    @pending_total = event_for_index.attendances.pending.count
    @accepted_total = event_for_index.attendances.accepted.count
    @paid_total = event_for_index.attendances.paid.count
    @cancelled_total = event_for_index.attendances.cancelled.count
    @total = event_for_index.attendances.count
    @total_without_cancelled = event_for_index.attendances.where.not(status: :cancelled).count
  end

  def show
    @attendance = resource
    @invoice = Invoice.for_attendance(@attendance.id).first
    respond_to do |format|
      format.html
      format.json
    end
  end

  def destroy
    attendance = resource
    attendance.cancel

    redirect_to attendance_path(attendance)
  end

  def confirm
    attendance = resource
    begin
      attendance.confirm
    rescue => ex
      flash[:alert] = t('flash.attendance.mail.fail', email: attendance.event.main_email_contact)
      Rails.logger.error('Airbrake notification failed. Logging error locally only')
      Rails.logger.error(ex.message)
    end
    respond_to do |format|
      format.html { redirect_to attendance_path(attendance) }
      format.js { responds_js }
    end
  end

  def pay_it
    resource.pay
    responds_js
  end

  def accept_it
    resource.accept
    responds_js
  end

  def recover_it
    resource.recover
    redirect_to attendance_path(resource)
  end

  def dequeue_it
    resource.dequeue
    redirect_to attendance_path(resource)
  end

  def search
    @attendances_list = AttendanceRepository.instance.search_for_list(event_for_index, params[:search], statuses_params)

    respond_to do |format|
      format.js {}
      format.csv do
        send_data AttendanceExportService.to_csv(@attendances_list), filename: 'attendances_list.csv'
      end
    end
  end

  private

  def resource_class
    Attendance
  end

  def resource
    Attendance.find(params[:id])
  end

  def load_event
    @event = resource.event
  end

  def event_for_index
    @event ||= Event.includes(registration_periods: [:event]).find_by_id(params.require(:event_id))
  end

  def responds_js
    respond_to do |format|
      @attendance = resource
      format.js { render :attendance }
    end
  end

  def statuses_params
    statuses = []
    statuses << :pending if params[:pending] == 'true'
    statuses << :accepted if params[:accepted] == 'true'
    statuses += %i(paid confirmed) if params[:paid] == 'true'
    statuses << :cancelled if params[:cancelled] == 'true'
    statuses
  end
end
