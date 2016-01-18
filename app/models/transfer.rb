class Transfer
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :origin_id, :origin, :destination_id, :destination
  PROTECTED_ATTRIBUTES = %i(id email_sent registration_date created_at updated_at status).freeze

  def self.build(attributes)
    origin = initialize_attendance(attributes[:origin_id])
    destination = initialize_attendance(attributes[:destination_id])

    Transfer.new(origin, destination)
  end

  def valid?
    !origin.new_record? && !destination.new_record? &&
      (origin.paid? || origin.confirmed?) && (destination.pending? || destination.accepted?)
  end

  def save
    destination.registration_value = origin.registration_value
    destination.pay if origin.paid?
    destination.confirm if origin.confirmed?

    origin.cancel
    origin.save && destination.save
  end

  def persisted?
    false
  end

  class << self
    protected

    def initialize_attendance(id)
      if id.nil?
        Attendance.new.tap { |a| a.status = '' }
      else
        Attendance.find id
      end
    end
  end

  protected

  def initialize(origin, destination)
    @origin = origin
    @origin_id = origin.id
    @destination = destination
    @destination_id = destination.id
  end
end
