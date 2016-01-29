class EventsController < ApplicationController
  layout 'eventless', only: %i(index list_archived)

  before_action :find_event, only: [:show, :destroy]
  skip_before_action :authenticate_user!, :authorize_action, only: [:index, :show]

  def index
    @events = Event.includes(:registration_periods).all.select { |event| event.end_date.present? && event.end_date > Time.zone.now }
  end

  def show
    @last_attendance_for_user = @event.attendances_for(current_user).last if current_user.present?
  end

  def list_archived
    @events = Event.includes(:registration_periods).ended
    render :index
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to event_path(@event)
    else
      render :new
    end
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_path }
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :attendance_limit, :start_date, :end_date, :full_price, :price_table_link)
  end

  def find_event
    @event = Event.find(params[:id])
  end
end
