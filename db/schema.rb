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

ActiveRecord::Schema.define(version: 2021_10_01_162719) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "user_id", null: false
    t.bigint "registration_group_id"
    t.datetime "registration_date"
    t.bigint "status"
    t.boolean "email_sent", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization", limit: 255
    t.string "country", limit: 255
    t.string "state", limit: 255
    t.string "city", limit: 255
    t.string "badge_name", limit: 255
    t.string "notes", limit: 255
    t.decimal "event_price", precision: 10
    t.bigint "registration_quota_id"
    t.decimal "registration_value", precision: 10
    t.bigint "registration_period_id"
    t.boolean "advised", default: false
    t.datetime "advised_at"
    t.integer "organization_size", default: 0
    t.integer "years_of_experience", default: 0
    t.integer "experience_in_agility", default: 0
    t.integer "education_level", default: 0
    t.bigint "queue_time"
    t.datetime "last_status_change_date"
    t.bigint "job_role", default: 0
    t.datetime "due_date"
    t.bigint "payment_type"
    t.bigint "registered_by_id", null: false
    t.string "other_job_role"
    t.integer "source_of_interest", default: 0, null: false
    t.boolean "welcome_email_sent", default: false
    t.integer "lock_version"
    t.index ["education_level"], name: "index_attendances_on_education_level"
    t.index ["event_id"], name: "idx_4539782_index_attendances_on_event_id"
    t.index ["registered_by_id"], name: "idx_4539782_fk_rails_4eb9f97929"
    t.index ["registration_period_id"], name: "idx_4539782_fk_rails_a2b9ca8d82"
    t.index ["registration_quota_id"], name: "idx_4539782_index_attendances_on_registration_quota_id"
    t.index ["source_of_interest"], name: "index_attendances_on_source_of_interest"
    t.index ["user_id"], name: "idx_4539782_index_attendances_on_user_id"
    t.index ["years_of_experience"], name: "index_attendances_on_years_of_experience"
  end

  create_table "authentications", force: :cascade do |t|
    t.bigint "user_id"
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "refresh_token", limit: 255
  end

  create_table "events", force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "attendance_limit"
    t.decimal "full_price", precision: 10
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "link", limit: 255
    t.bigint "days_to_charge", default: 7
    t.string "main_email_contact", limit: 255, null: false
    t.string "event_image", limit: 255
    t.string "country", limit: 255, null: false
    t.string "state", limit: 255, null: false
    t.string "city", limit: 255, null: false
    t.string "event_nickname"
    t.string "event_schedule_link"
    t.string "event_remote_manual_link"
    t.string "event_remote_platform_name"
    t.string "event_remote_platform_mail"
    t.boolean "event_remote", default: false
  end

  create_table "events_users", id: false, force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "user_id"
    t.index ["event_id"], name: "idx_4539840_index_events_users_on_event_id"
    t.index ["user_id"], name: "idx_4539840_index_events_users_on_user_id"
  end

  create_table "payment_notifications", force: :cascade do |t|
    t.text "params"
    t.string "status", limit: 255
    t.string "transaction_id", limit: 255
    t.string "payer_email", limit: 255
    t.decimal "settle_amount", precision: 10
    t.string "settle_currency", limit: 255
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "attendance_id"
    t.index ["attendance_id"], name: "idx_4539845_index_payment_notifications_on_attendance_id"
  end

  create_table "registration_groups", force: :cascade do |t|
    t.bigint "event_id"
    t.string "name", limit: 255
    t.bigint "capacity"
    t.bigint "discount"
    t.string "token", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "leader_id"
    t.bigint "minimum_size"
    t.decimal "amount", precision: 10
    t.boolean "automatic_approval", default: false
    t.bigint "registration_quota_id"
    t.boolean "paid_in_advance", default: false
  end

  create_table "registration_periods", force: :cascade do |t|
    t.bigint "event_id"
    t.string "title", limit: 255
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", precision: 10, null: false
  end

  create_table "registration_quotas", force: :cascade do |t|
    t.bigint "quota"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "event_id"
    t.bigint "registration_price_id"
    t.bigint "order"
    t.boolean "closed", default: false
    t.decimal "price", precision: 10, null: false
  end

  create_table "slack_configurations", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "room_webhook", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_slack_configurations_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", limit: 255, null: false
    t.string "last_name", limit: 255, null: false
    t.string "email", limit: 255, null: false
    t.string "country", limit: 255
    t.string "state", limit: 255
    t.string "city", limit: 255
    t.integer "gender", default: 5
    t.bigint "roles_mask"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "registration_group_id"
    t.bigint "role", default: 0, null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.bigint "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email", limit: 255
    t.bigint "failed_attempts", default: 0, null: false
    t.string "unlock_token", limit: 255
    t.datetime "locked_at"
    t.string "user_image", limit: 255
    t.date "birth_date"
    t.integer "education_level", default: 0
    t.string "school"
    t.integer "ethnicity", default: 0, null: false
    t.integer "disability", default: 5, null: false
    t.index ["confirmation_token"], name: "idx_4539890_index_users_on_confirmation_token", unique: true
    t.index ["disability"], name: "index_users_on_disability"
    t.index ["education_level"], name: "index_users_on_education_level"
    t.index ["email"], name: "idx_4539890_index_users_on_email", unique: true
    t.index ["ethnicity"], name: "index_users_on_ethnicity"
    t.index ["gender"], name: "index_users_on_gender"
    t.index ["registration_group_id"], name: "idx_4539890_fk_rails_ebe9fba698"
    t.index ["reset_password_token"], name: "idx_4539890_index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "idx_4539890_index_users_on_unlock_token", unique: true
  end

  add_foreign_key "attendances", "events", on_update: :restrict, on_delete: :restrict
  add_foreign_key "attendances", "registration_periods", on_update: :restrict, on_delete: :restrict
  add_foreign_key "attendances", "registration_quotas", on_update: :restrict, on_delete: :restrict
  add_foreign_key "attendances", "users", column: "registered_by_id", on_update: :restrict, on_delete: :restrict
  add_foreign_key "attendances", "users", on_update: :restrict, on_delete: :restrict
  add_foreign_key "payment_notifications", "attendances", on_update: :restrict, on_delete: :restrict
  add_foreign_key "slack_configurations", "events"
  add_foreign_key "users", "registration_groups", on_update: :restrict, on_delete: :restrict
end
