# encoding: UTF-8
class RegistrationGroupsController < ApplicationController

  before_action :find_event
  before_action :find_group, only: [:destroy]

  def index
    @groups = @event.registration_groups
  end

  def destroy
    @group.destroy
    redirect_to event_registration_groups_path(@event), notice: t('registration_group.destroy.success')
  end

  private

  def find_event
    @event = Event.find params[:event_id]
  rescue ActiveRecord::RecordNotFound
    redirect_to events_path, alert: t('event.not_found')
  end

  def find_group
    @group = RegistrationGroup.find_by(id: params[:id])
  end
end
