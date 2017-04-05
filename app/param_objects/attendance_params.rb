class AttendanceParams
  attr_reader :new_attributes, :user, :event, :request_params
  def initialize(user, event, request_params)
    @user = user
    @event = event
    @request_params = request_params
    @new_attributes = build_attributes
  end

  def attributes_hash
    @request_params[:attendance] && @request_params.require(:attendance).permit(
      :payment_type, :event_id, :user_id, :registration_group_id, :registration_date, :first_name, :last_name, :email,
      :organization, :organization_size, :job_role, :years_of_experience, :experience_in_agility,
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
    attributes[:user_id] = @user.id
    attributes[:registration_date] ||= Time.zone.now
    attributes
  end
end
