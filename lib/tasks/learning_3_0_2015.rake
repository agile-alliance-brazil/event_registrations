# encoding: utf-8

require 'faker'

namespace :learning_3_0_2015 do
  desc 'Generates seeds'
  task :seeds => :environment do
    event = Event.where('name like ?', '%Learning 3.0 Experience%').first
    if event.present?
      puts 'There is an event with the same name already'

      puts "#{event.name} - created at #{I18n.l(event.created_at)}"
    else
      print 'Learning 3.0 Experience '
      event = Event.create!(name: 'Learning 3.0 Experience', price_table_link: 'http://localhost:9292/link', full_price: 1500.00, start_date: Date.new(2015, 10, 16), end_date: Date.new(2015, 10, 17))

      # Quota
      RegistrationQuota.create!(event: event, quota: 10, price: 1000)
      RegistrationQuota.create!(event: event, quota: 10, price: 1150.00)

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
