# frozen_string_literal: true

class UpdateAttendance
  def self.run_for(update_params)
    params = update_params.request_params
    attendance = Attendance.find(params[:id])
    attendance.update(update_params.attributes_hash)
    attendance.update(payment_type: update_params.payment_type_params)
    attendance
  end
end
