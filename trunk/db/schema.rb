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

ActiveRecord::Schema.define(:version => 20100709152719) do

  create_table "ad_inventory_sources", :force => true do |t|
    t.text "name"
  end

  create_table "audiences", :force => true do |t|
    t.text    "description"
    t.text    "internal_external"
    t.integer "seed_extraction_id"
    t.integer "model_id"
  end

  create_table "audiences_campaigns", :id => false, :force => true do |t|
    t.integer "audience_id", :null => false
    t.integer "campaign_id", :null => false
  end

  create_table "campaigns", :force => true do |t|
    t.text    "description",   :null => false
    t.text    "campaign_code", :null => false
    t.date    "start_date"
    t.date    "end_date"
    t.integer "partner_id"
    t.integer "cid"
  end

  create_table "campaigns_msas", :id => false, :force => true do |t|
    t.integer "campaign_id", :null => false
    t.integer "msa_id",      :null => false
  end

  create_table "creative_sizes", :force => true do |t|
    t.float    "height"
    t.float    "width"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "creatives", :force => true do |t|
    t.text    "name"
    t.text    "media_type"
    t.integer "creative_size_id"
    t.integer "campaign_id"
  end

  create_table "custom_filters", :force => true do |t|
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_filters_line_items", :id => false, :force => true do |t|
    t.integer "custom_filter_id",    :null => false
    t.integer "insertion_orders_id", :null => false
    t.integer "line_item_id",        :null => false
  end

  create_table "insertion_orders", :force => true do |t|
    t.text     "description"
    t.integer  "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "line_items", :force => true do |t|
    t.integer  "impressions"
    t.float    "internal_pricing"
    t.float    "external_pricing"
    t.integer  "insertion_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "models", :force => true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "msas", :force => true do |t|
    t.text     "country"
    t.text     "region"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "seed_extractions", :force => true do |t|
    t.text     "description"
    t.text     "mapper"
    t.text     "reducer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
