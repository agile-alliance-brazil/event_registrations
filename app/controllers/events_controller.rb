# encoding: UTF-8
class EventsController < InheritedResources::Base
  layout :false, only: :index
  actions :index, :show

  skip_before_filter :authenticate_user!
end