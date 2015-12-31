# encoding: utf-8

require 'faker'

namespace :fearless_change_2015 do
  desc 'Generates seeds'
  task :seeds => :environment do
    event = Event.where('name like ?', '%Fearless Change%').first
    if event.present?
      puts 'There is an event with the same name already'

      puts "#{event.name} - created at #{I18n.l(event.created_at)}"
    else
      print 'Generating seeds fo Fearless Change: Patterns for Introducing New Ideas '
      event = Event.create!(name: 'Fearless Change: Patterns for Introducing New Ideas', price_table_link: 'http://localhost:9292/link', full_price: 840.00, start_date: Date.new(2015, 10, 19), end_date: Date.new(2015, 10, 19))

      # Quota
      RegistrationQuota.create!(event: event, quota: 10, price: 700)

      puts '√'
    end
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
