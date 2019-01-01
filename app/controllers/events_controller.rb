# frozen_string_literal: true

class EventsController < AuthenticatedController
  before_action :assign_event, only: %i[show destroy add_organizer remove_organizer edit update]

  before_action :check_organizer, only: %i[edit update destroy add_organizer]
  before_action :check_admin, only: %i[new create list_archived]

  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @events = Event.includes(:registration_periods).all.select { |event| event.end_date.present? && event.end_date >= Time.zone.now }
  end

  def show
    assign_organizers
    @last_attendance_for_user = AttendanceRepository.instance.attendances_for(@event, current_user).last if current_user.present?
  end

  def list_archived
    @events = Event.includes(:registration_periods).ended.order(start_date: :desc)
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

  def add_organizer
    organizer = User.find(params[:organizer])
    return not_found unless organizer.organizer? || organizer.admin?
    @event.add_organizer(organizer)
    assign_organizers
    respond_to { |format| format.js {} }
  end

  def remove_organizer
    organizer = User.find(params[:organizer])
    @event.remove_organizer(organizer)
    assign_organizers
    respond_to { |format| format.js { render 'events/add_organizer' } }
  end

  def edit; end

  def update
    if @event.update(event_params)
      redirect_to @event
    else
      render :edit
    end
  end

  private

  def assign_organizers
    @organizers_to_select = User.organizer.order(:first_name, :last_name) - @event.organizers
  end

  def event_params
    params.require(:event).permit(:event_image, :name, :attendance_limit, :days_to_charge, :start_date, :end_date, :city, :state, :country, :main_email_contact, :full_price, :price_table_link, :link, :logo)
  end

  def assign_event
    @event = Event.find(params[:id])
  end
end
