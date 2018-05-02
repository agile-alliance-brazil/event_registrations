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

ActiveRecord::Schema.define(version: 20180502154501) do

  create_table "attendances", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.integer "registration_group_id"
    t.datetime "registration_date"
    t.integer "status"
    t.boolean "email_sent", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "organization"
    t.string "phone"
    t.string "country"
    t.string "state"
    t.string "city"
    t.string "badge_name"
    t.string "cpf"
    t.string "gender"
    t.string "notes"
    t.decimal "event_price", precision: 10
    t.integer "registration_quota_id"
    t.decimal "registration_value", precision: 10
    t.integer "registration_period_id"
    t.boolean "advised", default: false
    t.datetime "advised_at"
    t.string "payment_type"
    t.string "organization_size"
    t.string "years_of_experience"
    t.string "experience_in_agility"
    t.string "school"
    t.string "education_level"
    t.integer "queue_time"
    t.datetime "last_status_change_date"
    t.integer "job_role", default: 0
    t.datetime "due_date"
    t.index ["registration_quota_id"], name: "index_attendances_on_registration_quota_id"
  end

  create_table "authentications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "refresh_token"
  end

  create_table "events", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "location_and_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "price_table_link"
    t.boolean "allow_voting"
    t.integer "attendance_limit"
    t.decimal "full_price", precision: 10
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "link"
    t.string "logo"
    t.integer "days_to_charge", default: 7
    t.string "main_email_contact", default: "", null: false
  end

  create_table "events_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_events_users_on_event_id"
    t.index ["user_id"], name: "index_events_users_on_user_id"
  end

  create_table "invoices", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "frete"
    t.decimal "amount", precision: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "registration_group_id"
    t.string "status"
    t.integer "payment_type", null: false
    t.string "invoiceable_type"
    t.integer "invoiceable_id"
    t.index ["invoiceable_type", "invoiceable_id"], name: "index_invoices_on_invoiceable_type_and_invoiceable_id"
  end

  create_table "payment_notifications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "params"
    t.string "status"
    t.string "transaction_id"
    t.string "payer_email"
    t.decimal "settle_amount", precision: 10
    t.string "settle_currency"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "invoice_id"
    t.index ["invoice_id"], name: "fk_rails_92030b1506"
  end

  create_table "registration_groups", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "event_id"
    t.string "name"
    t.integer "capacity"
    t.integer "discount"
    t.string "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "leader_id"
    t.integer "invoice_id"
    t.integer "minimum_size"
    t.decimal "amount", precision: 10
    t.boolean "automatic_approval", default: false
    t.integer "registration_quota_id"
    t.boolean "paid_in_advance", default: false
    t.index ["invoice_id"], name: "fk_rails_9544e3707e"
  end

  create_table "registration_periods", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "event_id"
    t.string "title"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "BRL", null: false
  end

  create_table "registration_quotas", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "quota"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_id"
    t.integer "registration_price_id"
    t.integer "order"
    t.boolean "closed", default: false
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "BRL", null: false
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "organization"
    t.string "phone"
    t.string "country"
    t.string "state"
    t.string "city"
    t.string "badge_name"
    t.string "cpf"
    t.string "gender"
    t.string "twitter_user"
    t.string "address"
    t.string "neighbourhood"
    t.string "zipcode"
    t.integer "roles_mask"
    t.string "default_locale", default: "pt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "registration_group_id"
    t.index ["registration_group_id"], name: "fk_rails_ebe9fba698"
  end

  add_foreign_key "payment_notifications", "invoices"
  add_foreign_key "registration_groups", "invoices"
  add_foreign_key "users", "registration_groups"
end
