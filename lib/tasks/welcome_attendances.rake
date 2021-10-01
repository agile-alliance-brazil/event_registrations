# frozen_string_literal: true

namespace :registration do
  desc 'Welcome the event attendances'
  task welcome_confirmed: :environment do
    WelcomeConfirmedAttendancesJob.perform_now
  end
end
