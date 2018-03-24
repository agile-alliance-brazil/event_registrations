# frozen_string_literal: true

module TransferHelper
  def attendance_as_select(attendances)
    attendances.collect { |p| { "#{p.id} - #{p.full_name}" => p.id } }.inject({}, &:merge) if attendances.present?
  end
end
