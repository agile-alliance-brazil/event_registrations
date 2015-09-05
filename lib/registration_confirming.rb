# encoding: UTF-8
class RegistrationConfirming
  def confirm
    events = Event.active_for(Time.zone.now)
    Rails.logger.info("Confirming paid attendances in #{events.count} events")
    events.each do |event|
      attendances_to_confirm = event.attendances.paid
      attendances_to_confirm.all.each do |attendance|
        next if attendance.grouped? && !attendance.registration_group.complete?
        Rails.logger.info("[Confirming Attendance] #{attendance.to_param}")
        attendance.confirm
      end
    end
  end
end
