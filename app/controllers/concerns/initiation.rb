module Concerns
  module Initiation
    extend ActiveSupport::Concern

    def resource_class
      Attendance
    end

    def resource
      Attendance.find_by_id(params[:id])
    end

    def build_attributes
      attributes = attendance_params || {}
      attributes = current_user.attendance_attributes.merge(attributes.symbolize_keys)
      attributes[:email_confirmation] ||= current_user.email
      attributes[:event_id] = event.id
      attributes[:user_id] = current_user.id
      if @registration_types.size == 1
        attributes[:registration_type_id] = @registration_types.first.id
      end
      attributes[:registration_date] ||= [event.end_date, Time.zone.now].min

      attributes
    end

    def load_registration_types
      @registration_types ||= valid_registration_types
    end

    def event
      @event ||= Event.includes(registration_types: [:event], registration_periods: [:event]).find_by_id(params.require(:event_id))
    end
  end
end