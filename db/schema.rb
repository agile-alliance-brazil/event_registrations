# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130325050103) do

  create_table "attendances", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.integer  "registration_type_id"
    t.integer  "registration_group_id"
    t.datetime "registration_date"
    t.string   "status"
    t.boolean  "email_sent",            :default => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "organization"
    t.string   "phone"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.string   "badge_name"
    t.string   "cpf"
    t.string   "gender"
    t.string   "twitter_user"
    t.string   "address"
    t.string   "neighbourhood"
    t.string   "zipcode"
  end

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.integer  "year"
    t.string   "location_and_date"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "payment_notifications", :force => true do |t|
    t.text     "params"
    t.string   "status"
    t.string   "transaction_id"
    t.integer  "invoicer_id"
    t.string   "payer_email"
    t.decimal  "settle_amount"
    t.string   "settle_currency"
    t.text     "notes"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "registration_periods", :force => true do |t|
    t.integer  "event_id"
    t.string   "title"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "registration_prices", :force => true do |t|
    t.integer  "registration_type_id"
    t.integer  "registration_period_id"
    t.decimal  "value"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "registration_types", :force => true do |t|
    t.integer  "event_id"
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "organization"
    t.string   "phone"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.string   "badge_name"
    t.string   "cpf"
    t.string   "gender"
    t.string   "twitter_user"
    t.string   "address"
    t.string   "neighbourhood"
    t.string   "zipcode"
    t.integer  "roles_mask"
    t.string   "default_locale", :default => "pt"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

end
