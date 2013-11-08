# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20131108162208) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "email"
    t.float    "total_cost"
    t.string   "payment_method"
    t.string   "transaction_number"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "discount"
    t.string   "delivery_method"
    t.string   "note"
  end

  create_table "events", force: true do |t|
    t.date     "date"
    t.string   "event_type"
    t.string   "invoice"
    t.date     "received_date"
    t.boolean  "received"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "oldsup"
    t.date     "expected_date"
    t.float    "additional_cost"
    t.integer  "supplier_id"
  end

  create_table "inventory_entries", force: true do |t|
    t.date     "date"
    t.string   "entry_type"
    t.string   "invoice_number"
    t.float    "light_count"
    t.boolean  "light_box"
    t.float    "medium_count"
    t.boolean  "medium_box"
    t.float    "heavy_count"
    t.boolean  "heavy_box"
    t.float    "robust_count"
    t.boolean  "robust_box"
    t.float    "power_count"
    t.boolean  "power_box"
    t.float    "strong_count"
    t.boolean  "strong_box"
    t.float    "monster_count"
    t.boolean  "monster_box"
    t.float    "agility_count"
    t.boolean  "agility_box"
    t.float    "explosive_count"
    t.boolean  "explosive_box"
    t.float    "hand_grip_count"
    t.boolean  "hand_grip_box"
    t.float    "ankle_grip_count"
    t.boolean  "ankle_grip_box"
    t.float    "door_strap_count"
    t.boolean  "door_strap_box"
    t.float    "small_metal_biner_count"
    t.boolean  "small_metal_biner_box"
    t.float    "small_rb_biner_count"
    t.boolean  "small_rb_biner_box"
    t.float    "large_biner_count"
    t.boolean  "large_biner_box"
    t.float    "hand_strap_count"
    t.boolean  "hand_strap_box"
    t.float    "travel_bag_count"
    t.boolean  "travel_bag_box"
    t.float    "dvd_count"
    t.boolean  "dvd_box"
    t.float    "sleeve_count"
    t.boolean  "sleeve_box"
    t.float    "manual_count"
    t.boolean  "manual_box"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "offering_products", force: true do |t|
    t.integer  "offering_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "offering_products", ["offering_id", "product_id"], name: "index_offering_products_on_offering_id_and_product_id", unique: true, using: :btree
  add_index "offering_products", ["offering_id"], name: "index_offering_products_on_offering_id", using: :btree
  add_index "offering_products", ["product_id"], name: "index_offering_products_on_product_id", using: :btree

  create_table "offerings", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float    "price"
  end

  create_table "orders", force: true do |t|
    t.string   "order_number"
    t.date     "date"
    t.integer  "offering_id"
    t.integer  "quantity"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "origin"
    t.integer  "customer_id"
  end

  create_table "product_counts", force: true do |t|
    t.integer  "event_id"
    t.integer  "product_id"
    t.float    "count"
    t.boolean  "is_box"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float    "price"
  end

  add_index "product_counts", ["event_id"], name: "index_product_counts_on_event_id", using: :btree
  add_index "product_counts", ["product_id"], name: "index_product_counts_on_product_id", using: :btree

  create_table "products", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "per_box"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "imloc"
    t.float    "weight"
    t.boolean  "display",     default: true
  end

  create_table "ship_terms", force: true do |t|
    t.string   "term"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "supplier_prices", force: true do |t|
    t.date     "date"
    t.integer  "supplier_id"
    t.integer  "product_id"
    t.integer  "ship_term_id"
    t.float    "quantity"
    t.float    "price"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "suppliers", force: true do |t|
    t.string   "name"
    t.string   "contact_name"
    t.string   "email"
    t.string   "payment_terms"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "phone_number"
    t.float    "shore_a_durometer"
    t.float    "tensile_strength"
    t.float    "ultimate_elongation"
    t.string   "comments"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
    t.string   "remember_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
