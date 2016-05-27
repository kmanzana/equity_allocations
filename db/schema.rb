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

ActiveRecord::Schema.define(version: 20160527121112) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.boolean  "savings_account", default: false
    t.integer  "routing_number"
    t.integer  "account_number"
    t.integer  "investor_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "crowd_pay_id"
    t.string   "account_name"
  end

  add_index "accounts", ["investor_id"], name: "index_accounts_on_investor_id", using: :btree

  create_table "investments", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "amount"
    t.integer  "number_of_shares"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "investments", ["account_id"], name: "index_investments_on_account_id", using: :btree

  create_table "investors", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "tax_id"
    t.boolean  "verified"
    t.integer  "crowd_pay_id"
    t.string   "crowd_pay_key"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "organization_name"
    t.datetime "birth_date"
    t.boolean  "foreign_address"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.boolean  "person"
    t.string   "email"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "annual_income"
    t.integer  "net_worth"
  end

  add_index "investors", ["crowd_pay_id"], name: "index_investors_on_crowd_pay_id", unique: true, using: :btree
  add_index "investors", ["crowd_pay_key"], name: "index_investors_on_crowd_pay_key", unique: true, using: :btree
  add_index "investors", ["tax_id"], name: "index_investors_on_tax_id", unique: true, using: :btree
  add_index "investors", ["user_id"], name: "index_investors_on_user_id", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "investment_id"
    t.integer  "crowd_pay_id"
    t.string   "command"
    t.integer  "amount"
    t.datetime "date"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "transactions", ["account_id"], name: "index_transactions_on_account_id", using: :btree
  add_index "transactions", ["investment_id"], name: "index_transactions_on_investment_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "remember_digest"
    t.string   "username"
    t.integer  "word_press_id"
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "accounts", "investors"
  add_foreign_key "investments", "accounts"
  add_foreign_key "investors", "users"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "investments"
end
