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

ActiveRecord::Schema[7.2].define(version: 2024_10_09_222135) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "inbound_webhooks", force: :cascade do |t|
    t.string "event", null: false
    t.string "status", default: "pending", null: false
    t.jsonb "payload", null: false
    t.string "controller_name", null: false
    t.text "error_message"
    t.string "source_ip"
    t.string "inbound_webhook_id"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event"], name: "index_inbound_webhooks_on_event"
    t.index ["inbound_webhook_id"], name: "index_inbound_webhooks_on_inbound_webhook_id", unique: true
    t.index ["status"], name: "index_inbound_webhooks_on_status"
  end
end
