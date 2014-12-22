# encoding: UTF-8
class EventsController < ApplicationController
  layout 'eventless', only: :index

  skip_before_filter :event, only: :index
  skip_before_filter :authenticate_user!
  skip_before_filter :authorize_action

  def index
    @events = Event.includes(:registration_periods).all.select do |event|
      event.registration_periods.ending_after(Time.now).present?
    end
  end

  def show
    @event = Event.find(params[:id])
  end
end
