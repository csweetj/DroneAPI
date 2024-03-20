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

ActiveRecord::Schema[7.0].define(version: 2024_03_17_134043) do
  create_table "drones", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "drone_registration_id", null: false
    t.integer "total_flight_time", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drone_registration_id"], name: "index_drones_on_drone_registration_id", unique: true
  end

  create_table "flights", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "drone_registration_id", null: false
    t.string "pilot_id", null: false
    t.decimal "take_off_latitude", precision: 10, scale: 6
    t.decimal "take_off_longitude", precision: 10, scale: 6
    t.decimal "landing_latitude", precision: 10, scale: 6
    t.decimal "landing_longitude", precision: 10, scale: 6
    t.datetime "take_off_time"
    t.datetime "landing_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
