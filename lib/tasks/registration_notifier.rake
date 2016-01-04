# encoding: UTF-8
require File.join(File.dirname(__FILE__), '../registration_notifier')

namespace :registration do
  desc 'Cancels registrations older than 7 days since the warning'
  task cancel: [:environment] do
    RegistrationNotifier.new.cancel
  end

  desc 'Notifies registrations older than 7 days of payment deadline'
  task warn: [:environment] do
    RegistrationNotifier.new.cancel_warning
  end
end
