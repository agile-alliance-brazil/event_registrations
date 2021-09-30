# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_30_193404) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "user_id", null: false
    t.integer "registration_group_id"
    t.datetime "registration_date"
    t.boolean "email_sent", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "organization"
    t.string "country"
    t.string "state"
    t.string "city"
    t.string "badge_name"
    t.string "notes"
    t.decimal "event_price"
    t.integer "registration_quota_id"
    t.decimal "registration_value", precision: 10
    t.integer "registration_period_id"
    t.boolean "advised", default: false
    t.datetime "advised_at"
    t.integer "organization_size", default: 0
    t.integer "years_of_experience", default: 0
    t.integer "experience_in_agility", default: 0
    t.integer "education_level", default: 0
    t.integer "queue_time"
    t.datetime "last_status_change_date"
    t.integer "job_role", default: 0
    t.datetime "due_date"
    t.integer "status"
    t.integer "payment_type"
    t.integer "registered_by_id", null: false
    t.string "other_job_role"
    t.integer "source_of_interest", default: 0, null: false
    t.index ["education_level"], name: "index_attendances_on_education_level"
    t.index ["event_id"], name: "index_attendances_on_event_id"
    t.index ["registration_quota_id"], name: "index_attendances_on_registration_quota_id"
    t.index ["source_of_interest"], name: "index_attendances_on_source_of_interest"
    t.index ["user_id"], name: "index_attendances_on_user_id"
    t.index ["years_of_experience"], name: "index_attendances_on_years_of_experience"
  end

  create_table "authentications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "refresh_token"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "attendance_limit"
    t.decimal "full_price"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "link"
    t.integer "days_to_charge", default: 7
    t.string "main_email_contact", default: "", null: false
    t.string "event_image"
    t.string "country", null: false
    t.string "state", null: false
    t.string "city", null: false
    t.string "event_nickname"
    t.string "event_schedule_link"
    t.string "event_remote_manual_link"
    t.string "event_remote_platform_name"
    t.string "event_remote_platform_mail"
    t.boolean "event_remote", default: false
  end

  create_table "events_users", id: false, force: :cascade do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_events_users_on_event_id"
    t.index ["user_id"], name: "index_events_users_on_user_id"
  end

  create_table "payment_notifications", id: :serial, force: :cascade do |t|
    t.text "params"
    t.string "status"
    t.string "transaction_id"
    t.string "payer_email"
    t.decimal "settle_amount"
    t.string "settle_currency"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "attendance_id"
    t.index ["attendance_id"], name: "index_payment_notifications_on_attendance_id"
  end

  create_table "registration_groups", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.string "name"
    t.integer "capacity"
    t.integer "discount"
    t.string "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "leader_id"
    t.integer "minimum_size"
    t.decimal "amount"
    t.boolean "automatic_approval", default: false
    t.integer "registration_quota_id"
    t.boolean "paid_in_advance", default: false
  end

  create_table "registration_periods", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.string "title"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "price", null: false
  end

  create_table "registration_quotas", id: :serial, force: :cascade do |t|
    t.integer "quota"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_id"
    t.integer "registration_price_id"
    t.integer "order"
    t.boolean "closed", default: false
    t.decimal "price", null: false
  end

  create_table "slack_configurations", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "room_webhook", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_slack_configurations_on_event_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "country"
    t.string "state"
    t.string "city"
    t.integer "gender", default: 5
    t.integer "roles_mask"
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
    t.date "birth_date"
    t.integer "education_level", default: 0
    t.string "school"
    t.integer "ethnicity", default: 0, null: false
    t.integer "disability", default: 5, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["disability"], name: "index_users_on_disability"
    t.index ["education_level"], name: "index_users_on_education_level"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["ethnicity"], name: "index_users_on_ethnicity"
    t.index ["gender"], name: "index_users_on_gender"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "attendances", "events"
  add_foreign_key "attendances", "registration_periods"
  add_foreign_key "attendances", "registration_quotas"
  add_foreign_key "attendances", "users"
  add_foreign_key "attendances", "users", column: "registered_by_id"
  add_foreign_key "payment_notifications", "attendances"
  add_foreign_key "slack_configurations", "events"
  add_foreign_key "users", "registration_groups"
end
