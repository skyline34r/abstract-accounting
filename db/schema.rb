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

ActiveRecord::Schema.define(:version => 20110520132236) do

  create_table "assets", :force => true do |t|
    t.string "tag"
  end

  add_index "assets", ["tag"], :name => "index_assets_on_tag", :unique => true

  create_table "balances", :force => true do |t|
    t.integer  "deal_id"
    t.string   "side"
    t.float    "amount"
    t.float    "value"
    t.datetime "start"
    t.datetime "paid"
  end

  add_index "balances", ["deal_id", "start"], :name => "index_balances_on_deal_id_and_start", :unique => true

  create_table "charts", :force => true do |t|
    t.integer "currency_id"
  end

  create_table "deals", :force => true do |t|
    t.string  "tag"
    t.float   "rate"
    t.integer "entity_id"
    t.integer "give_id"
    t.string  "give_type"
    t.integer "take_id"
    t.string  "take_type"
    t.boolean "isOffBalance", :default => false
  end

  add_index "deals", ["entity_id", "tag"], :name => "index_deals_on_entity_id_and_tag", :unique => true

  create_table "entities", :force => true do |t|
    t.string "tag"
  end

  create_table "facts", :force => true do |t|
    t.datetime "day"
    t.float    "amount"
    t.integer  "from_deal_id"
    t.integer  "to_deal_id"
    t.integer  "resource_id"
    t.string   "resource_type"
  end

  create_table "incomes", :force => true do |t|
    t.datetime "start"
    t.string   "side"
    t.float    "value"
    t.datetime "paid"
  end

  add_index "incomes", ["start"], :name => "index_incomes_on_start", :unique => true

  create_table "journals", :force => true do |t|
    t.integer  "fact_id"
    t.datetime "created_at"
    t.integer  "created_by_id"
  end

  add_index "journals", ["fact_id"], :name => "index_journals_on_fact_id", :unique => true

  create_table "money", :force => true do |t|
    t.integer "num_code"
    t.string  "alpha_code"
  end

  add_index "money", ["alpha_code"], :name => "index_money_on_alpha_code", :unique => true
  add_index "money", ["num_code"], :name => "index_money_on_num_code", :unique => true

  create_table "places", :force => true do |t|
    t.string "tag"
  end

  add_index "places", ["tag"], :name => "index_places_on_tag", :unique => true

  create_table "products", :force => true do |t|
    t.string  "unit"
    t.integer "resource_id"
  end

  add_index "products", ["resource_id"], :name => "index_products_on_resource_id", :unique => true

  create_table "quotes", :force => true do |t|
    t.integer  "money_id"
    t.datetime "day"
    t.float    "rate"
    t.float    "diff"
  end

  add_index "quotes", ["money_id", "day"], :name => "index_quotes_on_money_id_and_day", :unique => true

  create_table "roles", :force => true do |t|
    t.string "name"
    t.string "pages"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "rules", :force => true do |t|
    t.integer "deal_id"
    t.boolean "fact_side"
    t.boolean "change_side"
    t.float   "rate"
    t.string  "tag"
    t.integer "from_id"
    t.integer "to_id"
  end

  create_table "states", :force => true do |t|
    t.integer  "deal_id"
    t.string   "side"
    t.float    "amount"
    t.datetime "start"
    t.datetime "paid"
  end

  create_table "storehouse_releases", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "place_id"
    t.integer  "to_id"
    t.integer  "deal_id"
    t.datetime "created"
    t.integer  "state"
  end

  create_table "txns", :force => true do |t|
    t.integer "fact_id"
    t.float   "value"
    t.integer "status"
    t.float   "earnings"
  end

  add_index "txns", ["fact_id"], :name => "index_txns_on_fact_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.integer  "entity_id"
    t.integer  "place_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "waybills", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "place_id"
    t.integer  "from_id"
    t.integer  "deal_id"
    t.datetime "created"
    t.string   "vatin"
    t.string   "document_id"
  end

  add_index "waybills", ["deal_id"], :name => "index_waybills_on_deal_id", :unique => true
  add_index "waybills", ["document_id"], :name => "index_waybills_on_document_id", :unique => true

end
