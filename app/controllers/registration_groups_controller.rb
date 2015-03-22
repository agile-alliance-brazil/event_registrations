# encoding: UTF-8
class RegistrationGroupsController < ApplicationController

  def index
    @groups = Event.find(params[:event_id]).registration_groups
  rescue ActiveRecord::RecordNotFound
    redirect_to events_path, alert: t('event.not_found')
  end
end
