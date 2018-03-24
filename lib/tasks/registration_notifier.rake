# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '../registration_notifier')

namespace :registration do
  desc 'Cancels registrations older than 7 days since the warning'
  task cancel: [:environment] do
    RegistrationNotifier.instance.cancel
  end

  desc 'Notifies registrations older than 7 days of payment deadline'
  task warn: [:environment] do
    RegistrationNotifier.instance.cancel_warning
  end
end
