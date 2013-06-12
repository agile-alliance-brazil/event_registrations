# encoding: UTF-8
class RegistrationNotifier
  def cancel
    pending_attendances.older_than(30.days.ago).each do |attendance|
      Rails.logger.info("[Attendance] #{attendance.to_param}")
      try_with("CANCEL") do
        EmailNotifications.cancelling_registration(attendance).deliver
        attendance.cancel
      end
    end
  end

  def cancel_warning
    pending_attendances.older_than(7.days.ago).each do |attendance|
      Rails.logger.info("[Attendance] #{attendance.to_param}")
      try_with("WARN") do
        EmailNotifications.cancelling_registration_warning(attendance).deliver
      end
    end
  end

  def pending_attendances
    event = Event.find 1
    manual = event.registration_types.where('title like "%manual%"').first

    event.attendances.pending.without_registration_type(manual)
  end

  private

  def try_with(action)
    yield
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
