# frozen_string_literal: true

class WelcomeConfirmedAttendancesJob < ApplicationJob
  queue_as :default

  def perform
    Event.events_to_welcome_attendances.each do |event|
      event.attendances.confirmed.each do |attendance|
        I18n.with_locale(attendance.user_locale) do
          if attendance.event.event_remote?
            EmailNotificationsMailer.welcome_attendance_remote_event(attendance).deliver
          else
            EmailNotificationsMailer.welcome_attendance(attendance).deliver
          end
        end
      end
    end
  end
end
