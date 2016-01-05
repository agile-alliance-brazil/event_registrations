class RegistrationPeriodsController < ApplicationController
  before_action :check_event

  def new
    @registration_period = RegistrationPeriod.new
  end

  def create
    @registration_period = RegistrationPeriod.new(period_params.merge(event: @event))
    if @registration_period.save
      @registration_period = RegistrationPeriod.new
      redirect_to new_event_registration_period_path(@event, @registration_period)
    else
      render :new
    end
  end

  private

  def period_params
    params.require(:registration_period).permit(:title, :start_at, :end_at, :price)
  end

  def check_event
    not_found unless @event.present?
  end
end
