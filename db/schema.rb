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

ActiveRecord::Schema[7.2].define(version: 2026_08_20_133016) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "creator_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "status", default: 0, null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "proposed_name"
    t.text "proposed_bio"
    t.index ["status"], name: "index_creator_requests_on_status"
    t.index ["user_id"], name: "index_creator_requests_on_user_id"
  end

  create_table "dashboards", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_dashboards_on_user_id"
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "opponent_deck", null: false
    t.string "result", null: false
    t.text "description"
    t.integer "hand_quality", null: false
    t.datetime "played_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "dashboard_id", null: false
    t.integer "first_or_second", default: 0, null: false
    t.integer "reason_for_defeat"
    t.integer "number_of_mulligans"
    t.integer "game_mode", default: 0, null: false
    t.index ["dashboard_id"], name: "index_matches_on_dashboard_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "subscriber_id", null: false
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_subscriptions_on_creator_id"
    t.index ["subscriber_id", "creator_id"], name: "index_subscriptions_on_subscriber_id_and_creator_id", unique: true
    t.index ["subscriber_id"], name: "index_subscriptions_on_subscriber_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.string "name"
    t.text "bio"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "creator_requests", "users"
  add_foreign_key "dashboards", "users"
  add_foreign_key "matches", "dashboards"
  add_foreign_key "subscriptions", "users", column: "creator_id"
  add_foreign_key "subscriptions", "users", column: "subscriber_id"
end
