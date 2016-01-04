# encoding: utf-8

require 'faker'

namespace :safe_2015 do
  desc 'Generates seeds'
  task seeds: :environment do
    event = Event.where('name like ?', '%SAFe Agilist%').first
    if event.present?
      puts 'There is an event with the same name already'

      puts "#{event.name} - created at #{I18n.l(event.created_at)}"
    else
      print 'Generating seeds fo SAFe agilist '
      event = Event.create!(name: 'Certificação SAFe Agilist (SA)', price_table_link: 'http://localhost:9292/link', full_price: 1470.00, start_date: Date.new(2015, 10, 19), end_date: Date.new(2015, 10, 20))

      # Period
      RegistrationPeriod.create!(start_at: Date.new(2015, 8, 17), end_at: Date.new(2015, 8, 31), event: event, price: 1050)
      RegistrationPeriod.create!(start_at: Date.new(2015, 9, 1), end_at: Date.new(2015, 9, 30), event: event, price: 1260)
      RegistrationPeriod.create!(start_at: Date.new(2015, 10, 01), end_at: Date.new(2015, 10, 19), event: event, price: 1470)

      puts '√'
    end
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
