# encoding: UTF-8
class RegistrationNotifier
  def cancel
    event = Event.find 1
    event.attendances.select{|a| a.pending? && a.registration_date < 30.days.ago}.each do |attendance|
      Rails.logger.info("[Attendance] #{attendance.to_param}")
      try_with("CANCEL", attendance)
    end
  end

  private
  def try_with(action, attendance)
    EmailNotifications.cancelling_registration(attendance).deliver
    attendance.cancel
    Rails.logger.info("  [#{action}] OK")
  rescue => e
    Airbrake.notify(e)
    Rails.logger.info("  [FAILED #{action}] #{e.message}")
    puts e.message
    puts e.backtrace
  ensure
    Rails.logger.flush
  end
end
