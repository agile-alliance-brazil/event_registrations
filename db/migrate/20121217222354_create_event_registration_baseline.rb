class CreateEventRegistrationBaseline < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string      :name
      t.integer     :year
      t.string      :location_and_date
      t.timestamps
    end

    create_table :registration_periods do |t|
      t.references	:event

      t.string		:title
      t.datetime	:start_at
      t.datetime	:end_at

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

    create_table :attendances do |t|
      t.references :event
      t.references :user
      t.references :registration_type
      t.references :registration_group

      t.datetime :registration_date
      t.string :status

      t.boolean :email_sent, :default => false

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
  end
end
