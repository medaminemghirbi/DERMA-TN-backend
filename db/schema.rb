# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_11_26_091159) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blogs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.uuid "doctor_id", null: false
    t.uuid "maladie_id", null: false
    t.boolean "is_archived", default: false
    t.boolean "is_verified", default: false
    t.serial "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "consultations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "appointment", null: false
    t.integer "status", default: 0
    t.integer "appointment_type", default: 0
    t.boolean "is_archived", default: false
    t.uuid "doctor_id", null: false
    t.uuid "patient_id", null: false
    t.string "refus_reason"
    t.string "note"
    t.string "room_code"
    t.integer "order", default: 1
    t.boolean "is_payed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "custom_mails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "doctor_id"
    t.string "patient_id"
    t.string "subject"
    t.text "body"
    t.string "status", default: "sent"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "doctor_usages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "doctor_id", null: false
    t.integer "count", default: 0
    t.boolean "is_archived", default: false
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.uuid "doctor_id", null: false
    t.boolean "is_archived", default: false
    t.integer "order", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "holidays", force: :cascade do |t|
    t.string "holiday_name", null: false
    t.date "holiday_date", null: false
    t.boolean "is_archived", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "maladies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "maladie_name", null: false
    t.text "maladie_description"
    t.text "synonyms"
    t.text "symptoms"
    t.text "causes"
    t.text "treatments"
    t.text "prevention"
    t.text "diagnosis"
    t.text "references"
    t.serial "order"
    t.boolean "is_archived", default: false
    t.boolean "is_cancer", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body"
    t.boolean "is_archived", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sender_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "consultation_id"
    t.string "status"
    t.datetime "received_at"
    t.integer "order", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultation_id"], name: "index_notifications_on_consultation_id"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "consultation_id", null: false
    t.string "payment_id"
    t.integer "status", default: 0
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "phone_numbers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "doctor_id", null: false
    t.string "number", null: false
    t.string "phone_type", null: false
    t.boolean "is_archived", default: false
    t.boolean "is_primary", default: false
    t.integer "order", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "firstname"
    t.string "lastname"
    t.string "address"
    t.boolean "email_confirmed", default: false
    t.string "confirm_token"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.date "birthday"
    t.integer "gender", default: 0
    t.integer "civil_status", default: 0
    t.boolean "is_archived", default: false
    t.integer "order", default: 1
    t.string "type"
    t.string "location"
    t.string "specialization"
    t.float "latitude"
    t.float "longitude"
    t.string "description"
    t.string "code_doc"
    t.string "website"
    t.string "twitter"
    t.string "youtube"
    t.string "facebook"
    t.string "linkedin"
    t.string "phone_number"
    t.string "medical_history"
    t.integer "plan", default: 0
    t.integer "custom_limit", default: 0
    t.integer "radius", default: 1
    t.boolean "is_emailable", default: true
    t.boolean "is_notifiable", default: true
    t.boolean "is_smsable", default: true
    t.boolean "working_saturday", default: false
    t.boolean "working_on_line", default: false
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "language", default: "fr"
    t.string "confirmation_code"
    t.datetime "confirmation_code_generated_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "consultations", "users", column: "doctor_id"
  add_foreign_key "consultations", "users", column: "patient_id"
  add_foreign_key "doctor_usages", "users", column: "doctor_id"
  add_foreign_key "documents", "users", column: "doctor_id"
  add_foreign_key "phone_numbers", "users", column: "doctor_id"
end
