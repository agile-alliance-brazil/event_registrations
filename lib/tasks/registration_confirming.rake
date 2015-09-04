# encoding: UTF-8
require File.join(File.dirname(__FILE__), '../registration_confirming')

namespace :registration do
  desc 'Confirms paid registrations'
  task :confirm => [:environment] do
    RegistrationConfirming.new.confirm
  end
end
