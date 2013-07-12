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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130711211242) do

  create_table "customers", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "email"
    t.float    "total_cost"
    t.string   "payment_method"
    t.string   "transaction_number"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "discount"
    t.string   "delivery_method"
    t.string   "note"
  end

  create_table "events", :force => true do |t|
    t.date     "date"
    t.string   "event_type"
    t.string   "invoice"
    t.date     "received_date"
    t.boolean  "received"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "oldsup"
    t.date     "expected_date"
    t.float    "additional_cost"
    t.integer  "supplier_id"
  end

  create_table "offering_products", :force => true do |t|
    t.integer  "offering_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "offering_products", ["offering_id", "product_id"], :name => "index_offering_products_on_offering_id_and_product_id", :unique => true
  add_index "offering_products", ["offering_id"], :name => "index_offering_products_on_offering_id"
  add_index "offering_products", ["product_id"], :name => "index_offering_products_on_product_id"

  create_table "offerings", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.float    "price"
  end

  create_table "orders", :force => true do |t|
    t.string   "order_number"
    t.date     "date"
    t.integer  "offering_id"
    t.integer  "quantity"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "origin"
    t.integer  "customer_id"
  end

  create_table "product_counts", :force => true do |t|
    t.integer  "event_id"
    t.integer  "product_id"
    t.float    "count"
    t.boolean  "is_box"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.float    "price"
  end

  add_index "product_counts", ["event_id"], :name => "index_product_counts_on_event_id"
  add_index "product_counts", ["product_id"], :name => "index_product_counts_on_product_id"

  create_table "products", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "per_box"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "imloc"
    t.float    "weight"
  end

  create_table "suppliers", :force => true do |t|
    t.string   "name"
    t.string   "contact_name"
    t.string   "email"
    t.string   "payment_terms"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "password_digest"
    t.string   "remember_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
