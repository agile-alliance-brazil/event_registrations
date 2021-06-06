# frozen_string_literal: true

class AttendanceParams
  attr_reader :new_attributes, :registered_by, :event, :request_params

  def initialize(user, event, request_params)
    @registered_by = user
    @event = event
    @request_params = request_params
    @new_attributes = build_attributes
  end

  def attributes_hash
    @request_params[:attendance] && @request_params.require(:attendance).permit(
      :payment_type, :event_id, :user_id, :registration_group_id, :registration_date, :first_name, :last_name, :email,
      :organization, :organization_size, :job_role, :other_job_role, :years_of_experience, :experience_in_agility,
      :school, :education_level, :phone, :country, :state, :city, :badge_name, :cpf, :gender
    )
  end

  def payment_type_params
    @request_params['payment_type'] || 'gateway'
  end

  private

  def build_attributes
    attributes = attributes_hash || {}
    attributes[:status] = :pending
    attributes[:event_id] = @event.id
    attributes[:registered_by_id] = @registered_by.id
    attributes[:user_id] = user_for_attendance
    attributes[:registration_date] ||= Time.zone.now
    attributes[:state] = attributes[:state].try(:upcase)
    attributes.delete(:user_for_attendance)
    attributes
  end

  def user_for_attendance
    attributes_hash.try(:[], :user_id) || @registered_by.id
  end
end
