# encoding: utf-8

require 'faker'

namespace :edition_2015 do
  desc 'Generates seeds'
  task seeds: :environment do
    print 'Generating seeds '

    event = Event.create!(name: 'Agile Brazil 2015', price_table_link: 'http://localhost:9292/link', full_price: 840.00, start_date: Date.new(2015, 10, 21), end_date: Date.new(2015, 10, 23))

    # Period
    RegistrationPeriod.create!(title: 'First period', start_at: Date.new(2015, 10, 8), end_at: Date.new(2015, 10, 15), event: event, price: 740)
    RegistrationPeriod.create!(title: 'Second pediod', start_at: Date.new(2015, 10, 15), end_at: Date.new(2015, 10, 21), event: event, price: 840)

    # Quotes
    RegistrationQuota.create!(order: 1, event: event, quota: 100, price: 420)
    RegistrationQuota.create!(order: 2, event: event, quota: 150, price: 540)

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
