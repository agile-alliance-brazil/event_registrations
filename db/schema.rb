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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160221154305) do

  create_table "attendances", force: :cascade do |t|
    t.integer  "event_id",               limit: 4
    t.integer  "user_id",                limit: 4
    t.integer  "registration_group_id",  limit: 4
    t.datetime "registration_date"
    t.string   "status",                 limit: 255
    t.boolean  "email_sent",                                        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "email",                  limit: 255
    t.string   "organization",           limit: 255
    t.string   "phone",                  limit: 255
    t.string   "country",                limit: 255
    t.string   "state",                  limit: 255
    t.string   "city",                   limit: 255
    t.string   "badge_name",             limit: 255
    t.string   "cpf",                    limit: 255
    t.string   "gender",                 limit: 255
    t.string   "notes",                  limit: 255
    t.decimal  "event_price",                        precision: 10
    t.integer  "registration_quota_id",  limit: 4
    t.decimal  "registration_value",                 precision: 10
    t.integer  "registration_period_id", limit: 4
    t.boolean  "advised",                                           default: false
    t.datetime "advised_at"
    t.string   "payment_type",           limit: 255
    t.string   "organization_size",      limit: 255
    t.string   "job_role",               limit: 255
    t.string   "years_of_experience",    limit: 255
    t.string   "experience_in_agility",  limit: 255
    t.string   "school",                 limit: 255
    t.string   "education_level",        limit: 255
  end

  add_index "attendances", ["registration_quota_id"], name: "index_attendances_on_registration_quota_id", using: :btree

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.string   "provider",      limit: 255
    t.string   "uid",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "refresh_token", limit: 255
  end

  create_table "events", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "location_and_date",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "price_table_link",   limit: 255
    t.boolean  "allow_voting"
    t.integer  "attendance_limit",   limit: 4
    t.decimal  "full_price",                     precision: 10
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "link",               limit: 255
    t.string   "logo",               limit: 255
    t.integer  "days_to_charge",     limit: 4,                  default: 7
    t.string   "main_email_contact", limit: 255,                            null: false
  end

  create_table "events_users", id: false, force: :cascade do |t|
    t.integer "event_id", limit: 4
    t.integer "user_id",  limit: 4
  end

  add_index "events_users", ["event_id"], name: "index_events_users_on_event_id", using: :btree
  add_index "events_users", ["user_id"], name: "index_events_users_on_user_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "frete",                 limit: 4
    t.decimal  "amount",                            precision: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",               limit: 4
    t.integer  "registration_group_id", limit: 4
    t.string   "status",                limit: 255
    t.string   "payment_type",          limit: 255
    t.integer  "invoiceable_id",        limit: 4
    t.string   "invoiceable_type",      limit: 255
  end

  add_index "invoices", ["invoiceable_type", "invoiceable_id"], name: "index_invoices_on_invoiceable_type_and_invoiceable_id", using: :btree

  create_table "payment_notifications", force: :cascade do |t|
    t.text     "params",          limit: 65535
    t.string   "status",          limit: 255
    t.string   "transaction_id",  limit: 255
    t.string   "payer_email",     limit: 255
    t.decimal  "settle_amount",                 precision: 10
    t.string   "settle_currency", limit: 255
    t.text     "notes",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invoice_id",      limit: 4
  end

  add_index "payment_notifications", ["invoice_id"], name: "fk_rails_92030b1506", using: :btree

  create_table "registration_groups", force: :cascade do |t|
    t.integer  "event_id",           limit: 4
    t.string   "name",               limit: 255
    t.integer  "capacity",           limit: 4
    t.integer  "discount",           limit: 4
    t.string   "token",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "leader_id",          limit: 4
    t.integer  "invoice_id",         limit: 4
    t.integer  "minimum_size",       limit: 4
    t.decimal  "amount",                         precision: 10
    t.boolean  "automatic_approval",                            default: false
  end

  add_index "registration_groups", ["invoice_id"], name: "fk_rails_9544e3707e", using: :btree

  create_table "registration_periods", force: :cascade do |t|
    t.integer  "event_id",       limit: 4
    t.string   "title",          limit: 255
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "price_cents",    limit: 4,   default: 0,     null: false
    t.string   "price_currency", limit: 255, default: "BRL", null: false
  end

  create_table "registration_quotas", force: :cascade do |t|
    t.integer  "quota",                 limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id",              limit: 4
    t.integer  "registration_price_id", limit: 4
    t.integer  "order",                 limit: 4
    t.boolean  "closed",                            default: false
    t.integer  "price_cents",           limit: 4,   default: 0,     null: false
    t.string   "price_currency",        limit: 255, default: "BRL", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",            limit: 255
    t.string   "last_name",             limit: 255
    t.string   "email",                 limit: 255
    t.string   "organization",          limit: 255
    t.string   "phone",                 limit: 255
    t.string   "country",               limit: 255
    t.string   "state",                 limit: 255
    t.string   "city",                  limit: 255
    t.string   "badge_name",            limit: 255
    t.string   "cpf",                   limit: 255
    t.string   "gender",                limit: 255
    t.string   "twitter_user",          limit: 255
    t.string   "address",               limit: 255
    t.string   "neighbourhood",         limit: 255
    t.string   "zipcode",               limit: 255
    t.integer  "roles_mask",            limit: 4
    t.string   "default_locale",        limit: 255, default: "pt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "registration_group_id", limit: 4
  end

  add_index "users", ["registration_group_id"], name: "fk_rails_ebe9fba698", using: :btree

  add_foreign_key "payment_notifications", "invoices"
  add_foreign_key "registration_groups", "invoices"
  add_foreign_key "users", "registration_groups"
end
