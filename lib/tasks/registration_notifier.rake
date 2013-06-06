# encoding: UTF-8
require File.join(File.dirname(__FILE__), '../registration_notifier')

namespace :registration do

  desc "Cancel registrations older than 30 days with a note to attendees"
  task :cancel => [:environment] do
    RegistrationNotifier.new.cancel
  end
  
end
