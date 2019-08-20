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

ActiveRecord::Schema.define(version: 2019_01_03_134846) do

  create_table "attendances", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "user_id", null: false
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
    t.string "organization_size"
    t.string "years_of_experience"
    t.string "experience_in_agility"
    t.string "school"
    t.string "education_level"
    t.integer "queue_time"
    t.datetime "last_status_change_date"
    t.integer "job_role", default: 0
    t.datetime "due_date"
    t.integer "payment_type"
    t.integer "registered_by_id", null: false
    t.index ["event_id"], name: "index_attendances_on_event_id"
    t.index ["registered_by_id"], name: "fk_rails_4eb9f97929"
    t.index ["registration_period_id"], name: "fk_rails_a2b9ca8d82"
    t.index ["registration_quota_id"], name: "index_attendances_on_registration_quota_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "authentications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "refresh_token"
  end

  create_table "events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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
    t.string "event_image"
    t.string "country", null: false
    t.string "state", null: false
    t.string "city", null: false
  end

  create_table "events_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_events_users_on_event_id"
    t.index ["user_id"], name: "index_events_users_on_user_id"
  end

  create_table "payment_notifications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "params"
    t.string "status"
    t.string "transaction_id"
    t.string "payer_email"
    t.decimal "settle_amount", precision: 10
    t.string "settle_currency"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "attendance_id"
    t.index ["attendance_id"], name: "index_payment_notifications_on_attendance_id"
  end

  create_table "registration_groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "event_id"
    t.string "name"
    t.integer "capacity"
    t.integer "discount"
    t.string "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "leader_id"
    t.integer "minimum_size"
    t.decimal "amount", precision: 10
    t.boolean "automatic_approval", default: false
    t.integer "registration_quota_id"
    t.boolean "paid_in_advance", default: false
  end

  create_table "registration_periods", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "event_id"
    t.string "title"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "price", precision: 10, null: false
  end

  create_table "registration_quotas", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "quota"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_id"
    t.integer "registration_price_id"
    t.integer "order"
    t.boolean "closed", default: false
    t.decimal "price", precision: 10, null: false
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
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
    t.integer "role", default: 0, null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "user_image"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["registration_group_id"], name: "fk_rails_ebe9fba698"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "users_dup_temp", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "id", default: 0, null: false
    t.string "first_name", null: false
    t.string "email", null: false
  end

  add_foreign_key "attendances", "events"
  add_foreign_key "attendances", "registration_periods"
  add_foreign_key "attendances", "registration_quotas"
  add_foreign_key "attendances", "users"
  add_foreign_key "attendances", "users", column: "registered_by_id"
  add_foreign_key "payment_notifications", "attendances"
  add_foreign_key "users", "registration_groups"
end
