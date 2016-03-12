class WelcomeConfirmedAttendancesJob < ActiveJob::Base
  queue_as :default

  def perform
    Event.tomorrow_events.each do |event|
      event.attendances.confirmed.each do |attendance|
        EmailNotifications.welcome_attendance(attendance).deliver_now
      end
    end
  end
end
