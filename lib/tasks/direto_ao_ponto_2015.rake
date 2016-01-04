# encoding: utf-8

require 'faker'

namespace :direto_ao_ponto_2015 do
  desc 'Generates seeds'
  task seeds: :environment do
    print 'Generating seeds '

    event = Event.create!(name: 'Direto Ao Ponto; criando produtos de forma enxuta', price_table_link: 'http://localhost:9292/link', full_price: 699.00, start_date: Date.new(2015, 10, 16), end_date: Date.new(2015, 10, 16))
    # Quotes
    RegistrationQuota.create!(event: event, price: 369, quota: 10)
    RegistrationQuota.create!(event: event, price: 439, quota: 10)
    RegistrationQuota.create!(event: event, price: 549, quota: 10)

    puts '√'
  end

  desc 'Generates all'
  task all: [:seeds]

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
