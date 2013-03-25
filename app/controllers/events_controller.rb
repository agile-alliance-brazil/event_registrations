# encoding: UTF-8
class EventsController < InheritedResources::Base
  layout "eventless", only: :index
  actions :index, :show

  skip_before_filter :set_event, only: :index
  skip_before_filter :authenticate_user!
  skip_before_filter :authorize_action
end