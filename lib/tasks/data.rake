# encoding: utf-8

require 'faker'

namespace :data do
  unless Rails.env.production?
    desc 'Generates seeds'
    task :seeds => :environment do
      print 'Generating seeds '
      3.times do |count|
        event = Event.create!(name: Faker::Company.name, price_table_link: 'http://localhost:9292/link', full_price: 850.00)
        registration_period = RegistrationPeriod.create!(start_at: Time.zone.today - 1, end_at: Time.zone.today + (count + 1).months, event: event)
        registration_type = RegistrationType.create!(title: 'registration_type.individual', event: event)
        RegistrationPrice.create!(registration_type: registration_type, registration_period: registration_period, value: 100.00)
        10.times do
          attendance = Attendance.create!(
          first_name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              organization: Faker::Company.name,
              email: Faker::Internet.email,
              phone: Faker::PhoneNumber.cell_phone,
              country: Faker::Address.country,
              city: 'Rio de Janeiro',
              registration_type: registration_type,
              registration_date: Time.zone.now,
              user: User.last,
              event: event)
          RegistrationGroup.create!(name: Faker::Company.name, event: event, leader: User.last, attendances: [attendance], discount: 15, minimum_size: 10)
        end
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
end
