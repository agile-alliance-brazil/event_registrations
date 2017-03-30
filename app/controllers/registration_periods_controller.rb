class RegistrationPeriodsController < ApplicationController
  before_action :check_event
  before_action :find_period, only: %i(destroy edit update)

  def new
    @period = RegistrationPeriod.new
  end

  def create
    @period = RegistrationPeriod.new(period_params.merge(event: @event))
    if @period.save
      @period = RegistrationPeriod.new
      redirect_to new_event_registration_period_path(@event, @period)
    else
      render :new
    end
  end

  def destroy
    @period.destroy
    redirect_to @event
  end

  def update
    return redirect_to @event if @period.update(period_params)
    render :edit
  end

  private

  def find_period
    @period = @event.registration_periods.find(params[:id])
  end

  def period_params
    params.require(:registration_period).permit(:title, :start_at, :end_at, :price)
  end

  def check_event
    not_found if @event.blank?
  end

  def resource_class
    RegistrationPeriod
  end
end
