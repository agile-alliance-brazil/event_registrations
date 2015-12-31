class AttendanceParams
  attr_reader :new_attributes, :user, :event, :request_params
  def initialize(user, event, request_params)
    @user = user
    @event = event
    @request_params = request_params
    @new_attributes = build_attributes
  end

  def attributes_hash
    @request_params[:attendance].nil? ? nil : @request_params.require(:attendance).permit(
      :event_id, :user_id, :registration_group_id, :registration_date, :first_name, :last_name, :email,
      :email_confirmation, :organization, :phone, :country, :state, :city, :badge_name, :cpf, :gender, :twitter_user, :address, :neighbourhood, :zipcode, :notes)
  end

  def payment_type_params
    @request_params['payment_type'] || Invoice::GATEWAY
  end

  private

  def build_attributes
    attributes = attributes_hash || {}
    attributes = @user.attendance_attributes.merge(attributes.symbolize_keys)
    attributes[:email_confirmation] ||= @user.email
    attributes[:event_id] = @event.id
    attributes[:user_id] = @user.id
    attributes[:registration_date] ||= [@event.end_date, Time.zone.now].min
    attributes
  end
end
