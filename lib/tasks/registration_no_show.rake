# encoding: UTF-8
require File.join(File.dirname(__FILE__), '../registration_no_show')

namespace :registration do
  desc 'Marks registrations as no show'
  task :no_show => [:environment] do
    RegistrationNoShow.new.no_show
  end
end
