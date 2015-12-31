module Concerns
  module Initiation
    extend ActiveSupport::Concern

    def resource_class
      Attendance
    end

    def resource
      Attendance.find_by_id(params[:id])
    end

    def event
      @event ||= Event.includes(registration_periods: [:event]).find_by_id(params.require(:event_id))
    end
  end
end