class RegistrationNoShow
  include Singleton

  def no_show
    events = Event.ended
    Rails.logger.info("Marking attendances as no show for #{events.count} events")
    events.each do |event|
      attendances_to_no_show = event.attendances.pending + event.attendances.accepted
      attendances_to_no_show.each do |attendance|
        Rails.logger.info("[Marking as No Show Attendance] #{attendance.to_param}")
        attendance.mark_no_show
      end
    end
  end
end
