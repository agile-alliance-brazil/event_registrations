class RegistrationQuotasController < ApplicationController
  before_action :check_event

  def new
    @registration_quota = RegistrationQuota.new
  end

  def create
    @registration_quota = RegistrationQuota.new(quota_params.merge(event: @event))
    if @registration_quota.save
      @registration_quota = RegistrationQuota.new
      redirect_to new_event_registration_quota_path(@event, @registration_quota)
    else
      render :new
    end
  end

  private

  def quota_params
    params.require(:registration_quota).permit(:order, :price, :quota)
  end

  def check_event
    not_found unless @event.present?
  end
end
