# frozen_string_literal: true

class RegistrationQuotasController < AuthenticatedController
  before_action :assign_event
  before_action :assign_quota, only: %i[destroy edit update]

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

  def destroy
    @registration_quota.destroy
    redirect_to @event
  end

  def edit; end

  def update
    return redirect_to @event if @registration_quota.update(quota_params)

    render :edit
  end

  private

  def quota_params
    params.require(:registration_quota).permit(:order, :price, :quota)
  end

  def assign_event
    @event = Event.find(params[:event_id])
  end

  def assign_quota
    @registration_quota = @event.registration_quotas.find(params[:id])
  end
end
