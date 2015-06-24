class Transfer
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :origin_id, :origin, :destination_id, :destination
  PROTECTED_ATTRIBUTES = [:id, :email_sent, :registration_date, :created_at, :updated_at, :status]

  def self.build(attributes)
    origin = initialize_attendance(attributes[:origin_id])
    destination = initialize_attendance(attributes[:destination_id])

    Transfer.new(origin, destination)
  end

  def valid?
    !origin.new_record? && !destination.new_record? &&
      (origin.paid? || origin.confirmed?) && (destination.pending?)
  end

  def save
    original_attributes = assignable_attributes(origin)
    destination_attributes = assignable_attributes(destination)

    origin.attributes = destination_attributes
    destination.attributes = original_attributes

    origin.save && destination.save
  end

  def persisted?
    false
  end

  protected

  def self.initialize_attendance(id)
    if id.nil?
      Attendance.new.tap { |a| a.status = '' }
    else
      Attendance.find id
    end
  end

  def initialize(origin, destination)
    @origin = origin
    @origin_id = origin.id
    @destination = destination
    @destination_id = destination.id
  end

  def assignable_attributes(attendance)
    attendance.attributes.reject do |key, _value|
      PROTECTED_ATTRIBUTES.include?(key.to_sym)
    end
  end
end