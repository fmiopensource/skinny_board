# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091119144334) do

  create_table "companies", :force => true do |t|
    t.string   "name",              :limit => 100
    t.string   "basecamp_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.integer  "company_status_id",                :default => 1
    t.datetime "deleted_at"
    t.string   "subdomain"
  end

  create_table "company_statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_board_filters", :force => true do |t|
    t.integer "user_id",  :null => false
    t.string  "board_id", :null => false
    t.text    "filters"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "deleted_at"
    t.integer  "basecamp_id"
    t.string   "first_name",                :limit => 40
    t.string   "last_name",                 :limit => 40
    t.string   "avatar_url"
    t.string   "twitter_login"
    t.string   "twitter_password"
    t.integer  "company_id"
    t.string   "invited_code"
    t.string   "company_name"
    t.string   "password_reset_code",       :limit => 40
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
  end

end
