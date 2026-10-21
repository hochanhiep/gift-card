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

ActiveRecord::Schema[8.1].define(version: 2026_10_21_032146) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "brands", force: :cascade do |t|
    t.citext "name", null: false
    t.integer "state", default: 0, null: false
    t.jsonb "custom_fields", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_brands_on_name", unique: true
    t.check_constraint "state = ANY (ARRAY[0, 1])", name: "brands_state_valid"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.citext "name", null: false
    t.decimal "denomination", precision: 10, scale: 2, null: false
    t.integer "state", default: 0, null: false
    t.jsonb "custom_fields", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "products", "brands", on_delete: :restrict
end
