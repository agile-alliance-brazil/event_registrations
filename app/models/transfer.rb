# frozen_string_literal: true

class Transfer
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :origin_id, :origin, :destination_id, :destination
  PROTECTED_ATTRIBUTES = %i[id email_sent registration_date created_at updated_at status].freeze

  def self.build(attributes)
    origin = initialize_attendance(attributes[:origin_id])
    destination = initialize_attendance(attributes[:destination_id])

    Transfer.new(origin, destination)
  end

  def self.initialize_attendance(id)
    return Attendance.new.tap { |a| a.status = '' } if id.blank?

    Attendance.find(id)
  end

  def valid?
    !origin.new_record? && !destination.new_record? &&
      (origin.paid? || origin.confirmed?) && (destination.pending? || destination.accepted?)
  end

  def save
    return false unless valid?

    destination.registration_value = origin.registration_value
    destination.status = origin.status

    origin.cancelled!
    origin.save && destination.save
  end

  def persisted?
    false
  end

  protected

  def initialize(origin, destination)
    @origin = origin
    @origin_id = origin.id
    @destination = destination
    @destination_id = destination.id
  end
end
