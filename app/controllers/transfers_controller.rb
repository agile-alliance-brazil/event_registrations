# encoding: UTF-8
class TransfersController < ApplicationController
  before_filter :transfer
  layout 'eventless'

  def new
    @origins = ((current_user.organizer? || current_user.admin?) ? Attendance : current_user.attendances).paid
    @destinations = Attendance.pending
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
end
