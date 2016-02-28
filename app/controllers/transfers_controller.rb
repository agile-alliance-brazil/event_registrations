# encoding: UTF-8
class TransfersController < ApplicationController
  before_action :transfer
  before_action :attendance, only: [:new]
  layout 'eventless'

  def new
    event = @attendance.event
    @origins = ((current_user.organizer? || current_user.admin?) ? event.attendances : current_user.attendances).paid
    @destinations = event.attendances.pending
    @event = transfer.origin.event || transfer.destination.event || Event.new.tap { |e| e.name = 'missing' }
  end

  def create
    if transfer.valid? && transfer.save
      flash[:notice] = t('flash.transfer.success')
      redirect_to attendance_path(transfer.origin)
    else
      flash[:error] = t('flash.transfer.failure')
      render :new
    end
  end

  protected

  def transfer
    @transfer ||= Transfer.build(params[:transfer] || {})
  end

  def attendance
    @attendance = Attendance.find(params[:attendance_id])
  end
end
