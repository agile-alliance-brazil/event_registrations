# encoding: UTF-8
class RegistrationReminder
  def publish
    pending_attendances.each do |attendance|
      Rails.logger.info("[ATTENDANCE] #{attendance.to_param}")
      try_with("REMINDER") do
        EmailNotifications.registration_reminder(attendance).deliver
        sleep(5) unless Rails.env.test?
      end
    end
  end
  
  private
  def pending_attendances
    Attendance.all(:order => 'id', :conditions =>
      ['event_id = ? AND status = ? AND registration_type_id <> ? AND registration_date < ?',
        current_event.id, 'pending',
        RegistrationType.find_by_title('registration_type.group').id,
        Time.zone.local(2011, 5, 21)])
  end
  
  def try_with(action, &blk)
    blk.call
    Rails.logger.info("  [#{action}] OK")
  rescue => e
    Airbrake.notify(e)
    Rails.logger.info("  [FAILED #{action}] #{e.message}")
  ensure
    Rails.logger.flush
  end
  
  def current_event
    @current_event ||= Event.current
  end
end
