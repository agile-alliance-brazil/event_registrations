# encoding: utf-8

require 'faker'

namespace :edition_2015 do
  desc 'Generates seeds'
  task :seeds => :environment do
    print 'Generating seeds '

    event = Event.create!(name: 'Agile Brazil 2015', price_table_link: 'http://localhost:9292/link', full_price: 840.00)
    registration_type = RegistrationType.create!(title: 'registration_type.individual', event: event)

    # Period
    full_registration_period = RegistrationPeriod.create!(start_at: Date.new(2015, 10, 8), end_at: Date.new(2015, 10, 15), event: event)
    RegistrationPrice.create!(registration_type: registration_type, registration_period: full_registration_period, value: 740.00)

    last_minute_period = RegistrationPeriod.create!(start_at: Date.new(2015, 10, 15), end_at: Date.new(2015, 10, 23), event: event)
    RegistrationPrice.create!(registration_type: registration_type, registration_period: last_minute_period, value: 840.00)

    # Quotes
    seb_price = RegistrationPrice.create!(registration_type: registration_type, value: 420.00)
    RegistrationQuota.create!(event: event, registration_price: seb_price, quota: 100)

    eb_price = RegistrationPrice.create!(registration_type: registration_type, value: 540.00)
    RegistrationQuota.create!(event: event, registration_price: eb_price, quota: 150)

    puts '√'
  end

  desc 'Clean'
  task :clean => :environment do
    print 'Cleaning all '
    Dir["#{Rails.root}/app/models/*.rb"].each do |file|
      read_file = File.read(file)
      if active_record?(read_file) && !embedded?(read_file) && !user?(read_file)
        class_name = file.split('/').last.gsub('.rb', '').camelize
        self.class.const_get(class_name).__send__ :delete_all
      end
    end
    puts '√'
  end

  desc 'Generates all'
  task :all => [:clean, :seeds]

  private

  def embedded?(read_file)
    read_file.include?('embedded_in')
  end

  def user?(read_file)
    read_file.include?('User')
  end

  def active_record?(read_file)
    read_file.include?('ActiveRecord::Base')
  end
end
