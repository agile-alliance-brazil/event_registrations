# frozen_string_literal: true

class TransfersController < AuthenticatedController
  before_action :assign_event
  before_action :assign_transfer
  before_action :check_organizer

  def new
    attendances = can_manage_event? ? @event.attendances : current_user.attendances
    @origins = attendances.committed_to
    @destinations = @event.attendances.pending + @event.attendances.accepted
  end

  def create
    if @transfer.save
      flash[:notice] = t('flash.transfer.success')
      redirect_to event_attendance_path(@event, @transfer.origin)
    else
      flash[:error] = t('flash.transfer.failure')
      render :new
    end
  end

  private

  def can_manage_event?
    @event.organizers.include?(current_user) || current_user.admin?
  end

  def assign_event
    @event = Event.find(params[:event_id])
  end

  def assign_transfer
    @transfer = Transfer.build(params[:transfer] || {})
  end
end
