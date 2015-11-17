class EventsController < ApplicationController
  layout 'eventless', only: [:index, :list_archived]

  before_filter :event, only: [:show]

  skip_before_filter :authenticate_user!
  skip_before_filter :authorize_action

  def index
    @events = Event.includes(:registration_periods).all.select { |event| event.end_date.present? && event.end_date > Time.zone.now }
  end

  def show
    @event = Event.find(params[:id])
    @last_attendance_for_user = @event.attendances_for(current_user).last if current_user.present?
  end

  def list_archived
    @events = Event.includes(:registration_periods).ended
    render :index
  end
end
