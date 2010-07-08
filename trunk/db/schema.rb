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

ActiveRecord::Schema.define(:version => 20100707200106) do

  create_table "partner_beacon_requests", :force => true do |t|
    t.string   "host_ip"
    t.datetime "request_time"
    t.string   "request_url",      :limit => 1023
    t.integer  "status_code"
    t.string   "referer_url",      :limit => 511
    t.string   "user_agent",       :limit => 511
    t.integer  "pid"
    t.string   "user_agent_class"
    t.string   "xguid"
    t.string   "xgcid"
    t.string   "puid"
  end

  create_table "partners", :force => true do |t|
    t.string  "name"
    t.integer "pid"
  end

  add_index "partners", ["pid"], :name => "index_partners_on_pid", :unique => true

  create_table "semaphore_allocations", :force => true do |t|
    t.integer  "semaphore_resource_id",              :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "expires_at",                         :null => false
    t.integer  "pid"
    t.integer  "tid",                   :limit => 8
    t.string   "host"
    t.integer  "state",                              :null => false
  end

  create_table "semaphore_resources", :force => true do |t|
    t.string  "name",     :null => false
    t.string  "location"
    t.integer "capacity", :null => false
    t.integer "usage"
  end

end
