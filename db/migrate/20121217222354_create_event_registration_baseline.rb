class CreateEventRegistrationBaseline < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string      :name
      t.integer     :year
      t.string      :location_and_date
      t.timestamps
    end

    create_table :attendees do |t|
      t.references :event
      
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :organization
      t.string :phone
      t.string :country
      t.string :state
      t.string :city
      
      t.string :badge_name
      t.string :cpf
      t.string :gender
      t.string :twitter_user
      t.string :address
      t.string :neighbourhood
      t.string :zipcode
      
      t.references :registration_type
      t.references :registration_group
      t.string :status
      t.integer :course_attendances_count, :default => 0

      t.boolean :email_sent, :default => false
      t.text :notes

      t.datetime :registration_date
      t.string :uri_token

      t.string :default_locale, :default => :pt
      
      t.timestamps
    end

    create_table :courses do |t|
      t.references :event
      
      t.string :name
      t.string :full_name
      t.boolean :combine
      
      t.timestamps
    end

    create_table :registration_periods do |t|
      t.references	:event

      t.string		:title
      t.datetime	:start_at
      t.datetime	:end_at
      
      t.timestamps
    end

    create_table :course_prices do |t|
      t.references :course
      t.references :registration_period
      
      t.decimal :value
      
      t.timestamps
    end

    create_table :registration_types do |t|
      t.references :event
      
      t.string :title
      
      t.timestamps
    end

    create_table :registration_prices do |t|
      t.references :registration_type
      t.references :registration_period
      
      t.decimal :value
      
      t.timestamps
    end

    create_table :course_attendances do |t|
      t.references :course
      t.references :attendee
      
      t.timestamps
    end

    create_table :registration_groups do |t|
      t.string :name
      t.string :cnpj
      t.string :state_inscription
      t.string :municipal_inscription
      t.string :contact_name
      t.string :contact_email
      t.string :phone
      t.string :fax
      t.string :address
      t.string :neighbourhood
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :country
      
      t.integer :total_attendees
      t.boolean :email_sent, :default => false

      t.string :uri_token
      t.string :status

      t.text :notes

      t.timestamps
    end

    create_table :payment_notifications do |t|
      t.text :params
      t.string :status
      t.string :transaction_id
      t.integer :invoicer_id
      t.string :invoicer_type

      t.string :payer_email
      t.decimal :settle_amount
      t.string :settle_currency

      t.text :notes
      
      t.timestamps
    end

    create_table :pre_registrations do |t|
      t.references :conference
      
      t.string :email
      t.boolean :used
      
      t.timestamps
    end
  end
end
