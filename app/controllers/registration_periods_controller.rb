# == Schema Information
#
# Table name: registration_periods
#
#  id             :integer          not null, primary key
#  event_id       :integer
#  title          :string(255)
#  start_at       :datetime
#  end_at         :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  price_cents    :integer          default(0), not null
#  price_currency :string(255)      default("BRL"), not null
#

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

  def destroy
    @period = RegistrationPeriod.find(params[:id])
    @period.destroy
    redirect_to @event
  end

  private

  def period_params
    params.require(:registration_period).permit(:title, :start_at, :end_at, :price)
  end

  def check_event
    not_found unless @event.present?
  end

  def resource_class
    RegistrationPeriod
  end
end
