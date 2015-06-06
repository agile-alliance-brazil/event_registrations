# encoding: UTF-8
class AttendancesController < ApplicationController
  before_filter :load_event, except: :index
  skip_before_filter :attendance, only: :index
  skip_before_filter :authenticate_user!, only: :callback
  skip_before_filter :authorize_action, only: [:callback, :index]
  protect_from_forgery except: [:callback]

  def index
    @attendances_list = event_for_index.attendances.search_for_list(params[:search])
    @pending_total = event_for_index.attendances.pending.count
    @accepted_total = event_for_index.attendances.accepted.count
    @paid_total = event_for_index.attendances.paid.count
    @cancelled_total = event_for_index.attendances.cancelled.count
    @total = event_for_index.attendances.count
    @total_without_cancelled = event_for_index.attendances.where.not(status: :cancelled).count
  end

  def show
    @attendance = resource
    @invoice = Invoice.find_by(user: @attendance.user, payment_type: Invoice::GATEWAY)
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
      flash[:alert] = t('flash.attendance.mail.fail')
      Rails.logger.error('Airbrake notification failed. Logging error locally only')
      Rails.logger.error(ex.message)
    end

    redirect_to attendance_path(attendance)
  end

  def enable_voting
    attendance = resource
    if attendance.can_vote?
      authentication = current_user.authentications.where(provider: :submission_system).first
      result = authentication ? authentication.token.post('/api/user/make_voter').parsed : {}

      if result['success']
        flash[:notice] = t('flash.attendance.enable_voting.success', url: result['vote_url']).html_safe
      else
        flash[:error] = t('flash.attendance.enable_voting.missing_authentication')
      end
    end
    
    redirect_to :back
  end

  def voting_instructions
    @attendance = resource
    @submission_system_authentication = current_user.authentications.find_by_provider('submission_system')
  end

  def pay_it
    if resource.cancelled?
      flash[:alert] = t('flash.attendance.payment.error')
    else
      resource.pay
      flash[:notice] = t('flash.attendance.payment.success')
    end
    redirect_to attendances_path(event_id: @event.id)
  end

  def accept_it
    resource.accept
    flash[:notice] = t('flash.attendance.accepted.success')
    redirect_to attendances_path(event_id: @event.id)
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
    @event ||= Event.includes(registration_types: [:event], registration_periods: [:event]).find_by_id(params.require(:event_id))
  end
end
