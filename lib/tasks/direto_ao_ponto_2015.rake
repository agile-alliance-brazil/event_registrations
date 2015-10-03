# encoding: utf-8

require 'faker'

namespace :direto_ao_ponto_2015 do
  desc 'Generates seeds'
  task :seeds => :environment do
    print 'Generating seeds '

    event = Event.create!(name: 'Direto Ao Ponto; criando produtos de forma enxuta', price_table_link: 'http://localhost:9292/link', full_price: 699.00, start_date: Date.new(2015, 10, 16), end_date: Date.new(2015, 10, 16))
    registration_type = RegistrationType.create!(title: 'registration_type.individual', event: event)

    # Quotes
    seb_price = RegistrationPrice.create!(registration_type: registration_type, value: 369.00)
    RegistrationQuota.create!(event: event, registration_price: seb_price, quota: 10)

    eb_price = RegistrationPrice.create!(registration_type: registration_type, value: 439.00)
    RegistrationQuota.create!(event: event, registration_price: eb_price, quota: 10)

    normal_price = RegistrationPrice.create!(registration_type: registration_type, value: 549.00)
    RegistrationQuota.create!(event: event, registration_price: normal_price, quota: 10)

    puts '√'
  end

  desc 'Generates all'
  task :all => [:seeds]

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
