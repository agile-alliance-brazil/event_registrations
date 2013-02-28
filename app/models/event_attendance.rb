# encoding: UTF-8
class EventAttendance
  include ActiveModel::Validations
  include ActiveModel::Conversion

  delegate :first_name, :last_name, :email, :organization, :phone,
           :country, :state, :city, :badge_name, :cpf, :gender, :twitter_user, :address,
           :neighbourhood, :zipcode, :default_locale, :to => :user
  delegate :first_name=, :last_name=, :email=, :organization=, :phone=,
           :country=, :state=, :city=, :badge_name=, :cpf=, :gender=, :twitter_user=, :address=,
           :neighbourhood=, :zipcode=, :default_locale=, :to => :user
  delegate :registration_type, :registration_period, :registration_date, :registration_fee, :event, :to => :attendance
  delegate :registration_type_id, :registration_period_id, :registration_date_id, :to => :attendance


  validates_confirmation_of :email

  def initialize(attributes = {})
    @attributes = attributes.merge(:registration_date => Time.zone.now)
  end

  def read_attribute_for_validation(key)
    @attributes[key]
  end

  def save
    user.update_attributes(user_attributes) &&
      attendance.save
  end

  def valid?
    user.attributes=user_attributes
    super && user.valid? && attendance.valid?
  end

  def errors
    attendance.valid?
    attendance.errors
  end

  def persisted?
    false
  end

  def user
    @user ||= User.find(@attributes[:user_id])
  end

  def attendance_attribute_keys
    [:event_id, :user_id, :registration_type, :registration_group, :registration_date, :registration_type_id, :registration_group_id, :registration_date]
  end

  def attendance_attributes
    @attributes.select{|key, value| attendance_attribute_keys.include?(key.to_sym)}
  end

  def user_attributes
    invalid_user_attributes = [:email_confirmation, :user_id] + attendance_attribute_keys
    attrs = @attributes.reject{|key, value| invalid_user_attributes.include?(key.to_sym)}
    Rails.logger.error attrs
    attrs
  end

  def attendance
    @attendance ||= Attendance.new(attendance_attributes)
  end

  def email_confirmation
    @attributes[:email_confirmation]
  end

  def email_confirmation=(confirmation)
    @attributes[:email_confirmation] = confirmation
  end
end
