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

ActiveRecord::Schema[8.0].define(version: 2025_07_17_172908) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "armies", force: :cascade do |t|
    t.string "name"
    t.string "era"
    t.string "core_stat"
    t.string "unique_weapon"
    t.string "signature_ability"
    t.text "factual_basis"
    t.string "historical_commander"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "battle_replays", force: :cascade do |t|
    t.bigint "battle_id", null: false
    t.bigint "unit_id"
    t.bigint "target_id"
    t.integer "turn_number", null: false
    t.string "action_type", null: false
    t.jsonb "details", default: {}
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["battle_id", "created_at"], name: "index_battle_replays_on_battle_id_and_created_at"
    t.index ["battle_id", "turn_number"], name: "index_battle_replays_on_battle_id_and_turn_number"
    t.index ["battle_id"], name: "index_battle_replays_on_battle_id"
    t.index ["target_id"], name: "index_battle_replays_on_target_id"
    t.index ["unit_id"], name: "index_battle_replays_on_unit_id"
  end

  create_table "battle_units", force: :cascade do |t|
    t.bigint "battle_id", null: false
    t.bigint "unit_id", null: false
    t.bigint "army_id", null: false
    t.integer "health", default: 100, null: false
    t.integer "morale", default: 100, null: false
    t.integer "position_x", default: 0, null: false
    t.integer "position_y", default: 0, null: false
    t.integer "temp_attack_bonus", default: 0
    t.integer "temp_defense_bonus", default: 0
    t.integer "temp_morale_bonus", default: 0
    t.integer "temp_movement_bonus", default: 0
    t.datetime "last_ability_use"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["army_id"], name: "index_battle_units_on_army_id"
    t.index ["battle_id", "army_id"], name: "index_battle_units_on_battle_id_and_army_id"
    t.index ["battle_id", "position_x", "position_y"], name: "index_battle_units_on_battle_id_and_position_x_and_position_y"
    t.index ["battle_id", "unit_id"], name: "index_battle_units_on_battle_id_and_unit_id"
    t.index ["battle_id"], name: "index_battle_units_on_battle_id"
    t.index ["unit_id"], name: "index_battle_units_on_unit_id"
  end

  create_table "battlefield_effects", force: :cascade do |t|
    t.bigint "terrain_id", null: false
    t.bigint "army_id", null: false
    t.integer "heat_penalty"
    t.integer "mobility_penalty"
    t.integer "visibility_penalty"
    t.integer "disease_risk"
    t.integer "morale_modifier"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cold_penalty"
    t.integer "attack_modifier"
    t.integer "defense_modifier"
    t.index ["army_id"], name: "index_battlefield_effects_on_army_id"
    t.index ["terrain_id"], name: "index_battlefield_effects_on_terrain_id"
  end

  create_table "battles", force: :cascade do |t|
    t.string "name"
    t.bigint "terrain_id", null: false
    t.string "status"
    t.integer "current_turn"
    t.integer "max_turns"
    t.text "victory_conditions"
    t.text "educational_unlocks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "winner_id"
    t.string "outcome"
    t.index ["terrain_id"], name: "index_battles_on_terrain_id"
  end

  create_table "terrains", force: :cascade do |t|
    t.string "name"
    t.string "terrain_type"
    t.string "climate"
    t.integer "mobility_modifier"
    t.integer "heat_stress"
    t.integer "disease_risk"
    t.integer "visibility"
    t.text "description"
    t.text "historical_significance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cold_stress"
  end

  create_table "units", force: :cascade do |t|
    t.bigint "army_id", null: false
    t.string "name"
    t.string "unit_type"
    t.integer "attack"
    t.integer "defense"
    t.integer "health"
    t.integer "morale"
    t.integer "movement"
    t.string "special_ability"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "special_abilities"
    t.index ["army_id"], name: "index_units_on_army_id"
  end

  add_foreign_key "battle_replays", "battle_units", column: "target_id"
  add_foreign_key "battle_replays", "battle_units", column: "unit_id"
  add_foreign_key "battle_replays", "battles"
  add_foreign_key "battle_units", "armies"
  add_foreign_key "battle_units", "battles"
  add_foreign_key "battle_units", "units"
  add_foreign_key "battlefield_effects", "armies"
  add_foreign_key "battlefield_effects", "terrains"
  add_foreign_key "battles", "terrains"
  add_foreign_key "units", "armies"
end
