# == Schema Information
#
# Table name: registration_quotas
#
#  id                    :integer          not null, primary key
#  quota                 :integer
#  created_at            :datetime
#  updated_at            :datetime
#  event_id              :integer
#  registration_price_id :integer
#  order                 :integer
#  closed                :boolean          default(FALSE)
#  price_cents           :integer          default(0), not null
#  price_currency        :string(255)      default("BRL"), not null
#

class RegistrationQuotasController < ApplicationController
  before_action :event

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
    @quota = RegistrationQuota.find(params[:id])
    @quota.destroy
    redirect_to @event
  end

  private

  def quota_params
    params.require(:registration_quota).permit(:order, :price, :quota)
  end
end
