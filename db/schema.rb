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

ActiveRecord::Schema[8.1].define(version: 2026_10_24_015821) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "action", null: false
    t.string "record_type"
    t.bigint "record_id"
    t.jsonb "change_set", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.inet "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.index ["action", "created_at"], name: "index_audit_logs_on_action_and_created_at"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["record_type", "record_id"], name: "index_audit_logs_on_record_type_and_record_id"
    t.index ["user_id", "created_at"], name: "index_audit_logs_on_user_id_and_created_at"
  end

  create_table "brands", force: :cascade do |t|
    t.citext "name", null: false
    t.integer "state", default: 0, null: false
    t.jsonb "custom_fields", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_brands_on_name", unique: true
    t.check_constraint "state = ANY (ARRAY[0, 1])", name: "brands_state_valid"
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "product_id", null: false
    t.string "idempotency_key", null: false
    t.string "activation_number", null: false
    t.text "pin"
    t.decimal "denomination", precision: 10, scale: 2, null: false
    t.decimal "payout_rate", precision: 5, scale: 2, null: false
    t.integer "state", default: 0, null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activation_number"], name: "index_cards_on_activation_number", unique: true
    t.index ["client_id", "created_at"], name: "index_cards_on_client_id_and_created_at"
    t.index ["client_id", "idempotency_key"], name: "index_cards_on_client_id_and_idempotency_key", unique: true
    t.index ["created_at"], name: "index_cards_on_created_at"
    t.index ["product_id", "created_at"], name: "index_cards_on_product_id_and_created_at"
    t.check_constraint "(state = 1) = (cancelled_at IS NOT NULL)", name: "cards_cancelled_at_matches_state"
    t.check_constraint "denomination > 0::numeric", name: "cards_denomination_positive"
    t.check_constraint "payout_rate >= 0::numeric AND payout_rate <= 100::numeric", name: "cards_payout_rate_range"
    t.check_constraint "state = ANY (ARRAY[0, 1])", name: "cards_state_valid"
  end

  create_table "client_products", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "product_id"], name: "index_client_products_on_client_id_and_product_id", unique: true
    t.index ["product_id"], name: "index_client_products_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.citext "name", null: false
    t.decimal "denomination", precision: 10, scale: 2, null: false
    t.integer "state", default: 0, null: false
    t.jsonb "custom_fields", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pin_required", default: true, null: false
    t.index ["brand_id", "name"], name: "index_products_on_brand_id_and_name", unique: true
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.check_constraint "denomination > 0::numeric", name: "products_denomination_positive"
    t.check_constraint "state = ANY (ARRAY[0, 1])", name: "products_state_valid"
  end

  create_table "users", force: :cascade do |t|
    t.citext "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 1, null: false
    t.decimal "payout_rate", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "state = ANY (ARRAY[0, 1])", name: "users_state_valid"
  end

  add_foreign_key "cards", "products", on_delete: :restrict
  add_foreign_key "cards", "users", column: "client_id", on_delete: :restrict
  add_foreign_key "client_products", "products", on_delete: :restrict
  add_foreign_key "client_products", "users", column: "client_id", on_delete: :restrict
  add_foreign_key "products", "brands", on_delete: :restrict
end
