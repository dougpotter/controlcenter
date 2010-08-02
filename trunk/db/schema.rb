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

ActiveRecord::Schema.define(:version => 20100729211736) do

  create_table "ad_inventory_sources", :force => true do |t|
    t.text "name"
  end

  create_table "ad_inventory_sources_campaigns", :id => false, :force => true do |t|
    t.integer "campaign_id",            :null => false
    t.integer "ad_inventory_source_id", :null => false
  end

  add_index "ad_inventory_sources_campaigns", ["ad_inventory_source_id"], :name => "ad_inventory_sources_campaigns_ad_inventory_source_id_fk"
  add_index "ad_inventory_sources_campaigns", ["campaign_id"], :name => "ad_inventory_sources_campaigns_campaign_id_fk"

  create_table "audiences", :force => true do |t|
    t.text    "description"
    t.text    "internal_external"
    t.integer "seed_extraction_id"
    t.integer "model_id"
  end

  add_index "audiences", ["model_id"], :name => "audiences_model_id_fk"
  add_index "audiences", ["seed_extraction_id"], :name => "audiences_seed_extraction_id_fk"

  create_table "audiences_campaigns", :id => false, :force => true do |t|
    t.integer "audience_id", :null => false
    t.integer "campaign_id", :null => false
  end

  add_index "audiences_campaigns", ["audience_id"], :name => "audiences_campaigns_audience_id_fk"
  add_index "audiences_campaigns", ["campaign_id"], :name => "audiences_campaigns_campaign_id_fk"

  create_table "campaigns", :force => true do |t|
    t.text    "description",    :null => false
    t.text    "campaign_code",  :null => false
    t.integer "partner_id"
    t.integer "cid"
    t.integer "time_window_id"
  end

  add_index "campaigns", ["cid"], :name => "index_campaigns_on_cid", :unique => true
  add_index "campaigns", ["partner_id"], :name => "campaigns_partner_id_fk"
  add_index "campaigns", ["time_window_id"], :name => "campaigns_time_window_id_fk"

  create_table "campaigns_geographies", :id => false, :force => true do |t|
    t.integer "campaign_id",  :null => false
    t.integer "geography_id", :null => false
  end

  add_index "campaigns_geographies", ["campaign_id"], :name => "campaigns_geographies_campaign_id_fk"
  add_index "campaigns_geographies", ["geography_id"], :name => "campaigns_geographies_geography_id_fk"

  create_table "cities", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "click_counts", :force => true do |t|
    t.integer "campaign_id",            :null => false
    t.integer "creative_id",            :null => false
    t.integer "ad_inventory_source_id", :null => false
    t.integer "geography_id",           :null => false
    t.integer "audience_id",            :null => false
    t.integer "time_window_id",         :null => false
    t.integer "click_count",            :null => false
  end

  add_index "click_counts", ["ad_inventory_source_id"], :name => "click_counts_ad_inventory_source_id_fk"
  add_index "click_counts", ["audience_id"], :name => "click_counts_audience_id_fk"
  add_index "click_counts", ["campaign_id"], :name => "click_counts_campaign_id_fk"
  add_index "click_counts", ["creative_id"], :name => "click_counts_creative_id_fk"
  add_index "click_counts", ["geography_id"], :name => "click_counts_geography_id_fk"
  add_index "click_counts", ["time_window_id"], :name => "click_counts_time_window_id_fk"

  create_table "creative_sizes", :force => true do |t|
    t.float "height"
    t.float "width"
  end

  create_table "creatives", :force => true do |t|
    t.text    "name"
    t.text    "media_type"
    t.integer "creative_size_id"
    t.integer "campaign_id"
  end

  add_index "creatives", ["campaign_id"], :name => "creatives_campaign_id_fk"
  add_index "creatives", ["creative_size_id"], :name => "creatives_creative_size_id_fk"

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

  add_index "custom_filters_line_items", ["custom_filter_id"], :name => "custom_filters_line_items_custom_filter_id_fk"
  add_index "custom_filters_line_items", ["line_item_id"], :name => "custom_filters_line_items_line_item_id_fk"

  create_table "geo_components", :force => true do |t|
    t.string  "description",  :null => false
    t.integer "state_id",     :null => false
    t.integer "geography_id", :null => false
  end

  add_index "geo_components", ["geography_id"], :name => "geo_components_geography_id_fk"
  add_index "geo_components", ["state_id"], :name => "geo_components_state_id_fk"

  create_table "geographies", :force => true do |t|
    t.string "description"
  end

  create_table "geographies_cities", :force => true do |t|
    t.integer "city_id"
    t.integer "geography_id"
  end

  create_table "geographies_states", :force => true do |t|
    t.integer "state_id"
    t.integer "geography_id"
  end

  create_table "impression_counts", :force => true do |t|
    t.integer "time_window_id",         :null => false
    t.integer "campaign_id",            :null => false
    t.integer "creative_id",            :null => false
    t.integer "ad_inventory_source_id", :null => false
    t.integer "geography_id",           :null => false
    t.integer "audience_id",            :null => false
    t.integer "impression_count",       :null => false
  end

  add_index "impression_counts", ["ad_inventory_source_id"], :name => "impression_counts_ad_inventory_source_id_fk"
  add_index "impression_counts", ["audience_id"], :name => "impression_counts_audience_id_fk"
  add_index "impression_counts", ["campaign_id"], :name => "impression_counts_campaign_id_fk"
  add_index "impression_counts", ["creative_id"], :name => "impression_counts_creative_id_fk"
  add_index "impression_counts", ["geography_id"], :name => "impression_counts_geography_id_fk"
  add_index "impression_counts", ["time_window_id"], :name => "impression_counts_time_window_id_fk"

  create_table "insertion_orders", :force => true do |t|
    t.text    "description"
    t.integer "campaign_id"
  end

  add_index "insertion_orders", ["campaign_id"], :name => "insertion_orders_campaign_id_fk"

  create_table "line_items", :force => true do |t|
    t.integer "impressions"
    t.float   "internal_pricing"
    t.float   "external_pricing"
    t.integer "insertion_order_id"
  end

  create_table "models", :force => true do |t|
    t.string "description"
  end

  create_table "partner_beacon_requests", :force => true do |t|
    t.string   "host_ip"
    t.datetime "request_time"
    t.string   "request_url",      :limit => 1023
    t.integer  "status_code"
    t.string   "referer_url",      :limit => 511
    t.string   "user_agent",       :limit => 511
    t.integer  "partner_id"
    t.string   "user_agent_class"
    t.string   "xguid"
    t.string   "xgcid"
    t.string   "puid"
  end

  create_table "partners", :force => true do |t|
    t.string "name"
  end

  create_table "remote_placements", :force => true do |t|
    t.integer "campaign_id",            :null => false
    t.integer "geography_id",           :null => false
    t.integer "audience_id",            :null => false
    t.integer "time_window_id",         :null => false
    t.integer "remote_placement_count", :null => false
  end

  add_index "remote_placements", ["audience_id"], :name => "remote_placements_audience_id_fk"
  add_index "remote_placements", ["campaign_id"], :name => "remote_placements_campaign_id_fk"
  add_index "remote_placements", ["geography_id"], :name => "remote_placements_geography_id_fk"
  add_index "remote_placements", ["time_window_id"], :name => "remote_placements_time_window_id_fk"

  create_table "seed_extractions", :force => true do |t|
    t.text "description"
    t.text "mapper"
    t.text "reducer"
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

  create_table "states", :force => true do |t|
    t.string "abbreviation", :null => false
  end

  create_table "time_windows", :force => true do |t|
    t.datetime "window_begin"
    t.datetime "window_end"
  end

  add_foreign_key "ad_inventory_sources_campaigns", "ad_inventory_sources", :name => "ad_inventory_sources_campaigns_ad_inventory_source_id_fk"
  add_foreign_key "ad_inventory_sources_campaigns", "campaigns", :name => "ad_inventory_sources_campaigns_campaign_id_fk"

  add_foreign_key "audiences", "models", :name => "audiences_model_id_fk"
  add_foreign_key "audiences", "seed_extractions", :name => "audiences_seed_extraction_id_fk"

  add_foreign_key "audiences_campaigns", "audiences", :name => "audiences_campaigns_audience_id_fk"
  add_foreign_key "audiences_campaigns", "campaigns", :name => "audiences_campaigns_campaign_id_fk"

  add_foreign_key "campaigns", "partners", :name => "campaigns_partner_id_fk"
  add_foreign_key "campaigns", "time_windows", :name => "campaigns_time_window_id_fk"

  add_foreign_key "campaigns_geographies", "campaigns", :name => "campaigns_geographies_campaign_id_fk"
  add_foreign_key "campaigns_geographies", "geographies", :name => "campaigns_geographies_geography_id_fk"

  add_foreign_key "click_counts", "ad_inventory_sources", :name => "click_counts_ad_inventory_source_id_fk"
  add_foreign_key "click_counts", "audiences", :name => "click_counts_audience_id_fk"
  add_foreign_key "click_counts", "campaigns", :name => "click_counts_campaign_id_fk"
  add_foreign_key "click_counts", "creatives", :name => "click_counts_creative_id_fk"
  add_foreign_key "click_counts", "geographies", :name => "click_counts_geography_id_fk"
  add_foreign_key "click_counts", "time_windows", :name => "click_counts_time_window_id_fk"

  add_foreign_key "creatives", "campaigns", :name => "creatives_campaign_id_fk"
  add_foreign_key "creatives", "creative_sizes", :name => "creatives_creative_size_id_fk"

  add_foreign_key "custom_filters_line_items", "custom_filters", :name => "custom_filters_line_items_custom_filter_id_fk"
  add_foreign_key "custom_filters_line_items", "line_items", :name => "custom_filters_line_items_line_item_id_fk"

  add_foreign_key "geo_components", "geographies", :name => "geo_components_geography_id_fk"
  add_foreign_key "geo_components", "states", :name => "geo_components_state_id_fk"

  add_foreign_key "impression_counts", "ad_inventory_sources", :name => "impression_counts_ad_inventory_source_id_fk"
  add_foreign_key "impression_counts", "audiences", :name => "impression_counts_audience_id_fk"
  add_foreign_key "impression_counts", "campaigns", :name => "impression_counts_campaign_id_fk"
  add_foreign_key "impression_counts", "creatives", :name => "impression_counts_creative_id_fk"
  add_foreign_key "impression_counts", "geographies", :name => "impression_counts_geography_id_fk"
  add_foreign_key "impression_counts", "time_windows", :name => "impression_counts_time_window_id_fk"

  add_foreign_key "insertion_orders", "campaigns", :name => "insertion_orders_campaign_id_fk"

  add_foreign_key "remote_placements", "audiences", :name => "remote_placements_audience_id_fk"
  add_foreign_key "remote_placements", "campaigns", :name => "remote_placements_campaign_id_fk"
  add_foreign_key "remote_placements", "geographies", :name => "remote_placements_geography_id_fk"
  add_foreign_key "remote_placements", "time_windows", :name => "remote_placements_time_window_id_fk"

end
