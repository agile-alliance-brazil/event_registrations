# encoding: UTF-8
class RegistrationNotifier
  def cancel
    Event.active_for(Time.zone.now).each do |event|
      pending_attendances(event).older_than(30.days.ago).each do |attendance|
        Rails.logger.info("[Attendance] #{attendance.to_param}")
        try_with('CANCEL') do
          EmailNotifications.cancelling_registration(attendance).deliver_now
          attendance.cancel
        end
      end
    end
  end

  def cancel_warning
    Event.active_for(Time.zone.now).each do |event|
      pending_attendances(event).older_than(7.days.ago).each do |attendance|
        Rails.logger.info("[Attendance] #{attendance.to_param}")
        try_with('WARN') do
          EmailNotifications.cancelling_registration_warning(attendance).deliver_now
        end
      end
    end
  end

  def pending_attendances(event)
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
  ensure
    Rails.logger.flush
  end
end
