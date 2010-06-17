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

ActiveRecord::Schema.define(:version => 20100504150514) do

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

end
