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

ActiveRecord::Schema.define(:version => 20100825205845) do

  create_table "ad_inventory_sources", :force => true do |t|
    t.string "name"
    t.string "ais_code", :null => false
  end

  add_index "ad_inventory_sources", ["ais_code"], :name => "index_ad_inventory_sources_on_ais_code", :unique => true

  create_table "ad_inventory_sources_campaigns", :id => false, :force => true do |t|
    t.integer "campaign_id",            :null => false
    t.integer "ad_inventory_source_id", :null => false
  end

  add_index "ad_inventory_sources_campaigns", ["ad_inventory_source_id"], :name => "ad_inventory_sources_campaigns_ad_inventory_source_id_fk"
  add_index "ad_inventory_sources_campaigns", ["campaign_id"], :name => "ad_inventory_sources_campaigns_campaign_id_fk"

  create_table "audiences", :force => true do |t|
    t.string "description"
    t.string "audience_code", :null => false
  end

  add_index "audiences", ["audience_code"], :name => "index_audiences_on_audience_code", :unique => true

  create_table "audiences_campaigns", :id => false, :force => true do |t|
    t.integer "audience_id", :null => false
    t.integer "campaign_id", :null => false
  end

  add_index "audiences_campaigns", ["audience_id"], :name => "audiences_campaigns_audience_id_fk"
  add_index "audiences_campaigns", ["campaign_id"], :name => "audiences_campaigns_campaign_id_fk"

  create_table "campaigns", :force => true do |t|
    t.string   "description",   :default => "", :null => false
    t.string   "campaign_code", :default => "", :null => false
    t.integer  "partner_id"
    t.datetime "start_time"
    t.datetime "end_time"
  end

  add_index "campaigns", ["campaign_code"], :name => "index_campaigns_on_campaign_code", :unique => true
  add_index "campaigns", ["partner_id"], :name => "campaigns_partner_id_fk"

  create_table "campaigns_geographies", :id => false, :force => true do |t|
    t.integer "campaign_id",  :null => false
    t.integer "geography_id", :null => false
  end

  add_index "campaigns_geographies", ["campaign_id"], :name => "campaigns_geographies_campaign_id_fk"
  add_index "campaigns_geographies", ["geography_id"], :name => "campaigns_geographies_geography_id_fk"

  create_table "cities", :force => true do |t|
    t.string  "name",      :null => false
    t.integer "region_id", :null => false
  end

  add_index "cities", ["region_id"], :name => "cities_region_id_fk"

  create_table "click_counts", :id => false, :force => true do |t|
    t.integer  "campaign_id",            :null => false
    t.integer  "creative_id",            :null => false
    t.integer  "ad_inventory_source_id", :null => false
    t.integer  "geography_id"
    t.integer  "audience_id",            :null => false
    t.integer  "click_count",            :null => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "duration_in_minutes"
  end

  add_index "click_counts", ["ad_inventory_source_id"], :name => "click_counts_ad_inventory_source_id_fk"
  add_index "click_counts", ["audience_id"], :name => "click_counts_audience_id_fk"
  add_index "click_counts", ["campaign_id", "creative_id", "ad_inventory_source_id", "audience_id", "start_time", "end_time", "duration_in_minutes"], :name => "click_counts_required_columns", :unique => true
  add_index "click_counts", ["campaign_id", "creative_id", "ad_inventory_source_id", "audience_id", "start_time", "end_time", "duration_in_minutes"], :name => "required_columns", :unique => true
  add_index "click_counts", ["campaign_id"], :name => "click_counts_campaign_id_fk"
  add_index "click_counts", ["creative_id"], :name => "click_counts_creative_id_fk"
  add_index "click_counts", ["geography_id"], :name => "click_counts_geography_id_fk"

  create_table "countries", :force => true do |t|
    t.string "name",         :null => false
    t.string "country_code"
  end

  create_table "creative_sizes", :force => true do |t|
    t.float  "height"
    t.float  "width"
    t.string "common_name"
  end

  create_table "creatives", :force => true do |t|
    t.string  "name"
    t.string  "media_type"
    t.integer "creative_size_id", :null => false
    t.string  "creative_code",    :null => false
  end

  add_index "creatives", ["creative_size_id"], :name => "creatives_creative_size_id_fk"

  create_table "custom_filters", :force => true do |t|
    t.string   "description"
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

  create_table "data_provider_channels", :force => true do |t|
    t.integer "data_provider_id", :null => false
    t.string  "name",             :null => false
    t.integer "update_frequency"
  end

  add_index "data_provider_channels", ["data_provider_id"], :name => "data_provider_channels_data_provider_id_fk"

  create_table "data_provider_files", :force => true do |t|
    t.integer "data_provider_channel_id", :null => false
    t.string  "url",                      :null => false
    t.integer "status",                   :null => false
  end

  add_index "data_provider_files", ["data_provider_channel_id"], :name => "data_provider_files_data_provider_channel_id_fk"

  create_table "data_providers", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "geographies", :force => true do |t|
    t.integer "country_id", :null => false
    t.integer "msa_id",     :null => false
    t.integer "zip_id",     :null => false
    t.integer "region_id",  :null => false
  end

  add_index "geographies", ["country_id"], :name => "geographies_country_id_fk"
  add_index "geographies", ["msa_id"], :name => "geographies_msa_id_fk"
  add_index "geographies", ["region_id"], :name => "geographies_region_id_fk"
  add_index "geographies", ["zip_id"], :name => "geographies_zip_id_fk"

  create_table "impression_counts", :id => false, :force => true do |t|
    t.integer  "campaign_id",            :null => false
    t.integer  "creative_id",            :null => false
    t.integer  "ad_inventory_source_id", :null => false
    t.integer  "geography_id"
    t.integer  "audience_id",            :null => false
    t.integer  "impression_count",       :null => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "duration_in_minutes"
  end

  add_index "impression_counts", ["ad_inventory_source_id"], :name => "impression_counts_ad_inventory_source_id_fk"
  add_index "impression_counts", ["audience_id"], :name => "impression_counts_audience_id_fk"
  add_index "impression_counts", ["campaign_id", "creative_id", "ad_inventory_source_id", "audience_id", "start_time", "end_time", "duration_in_minutes"], :name => "impression_counts_required_columns", :unique => true
  add_index "impression_counts", ["campaign_id", "creative_id", "ad_inventory_source_id", "audience_id", "start_time", "end_time", "duration_in_minutes"], :name => "required_columns", :unique => true
  add_index "impression_counts", ["campaign_id"], :name => "impression_counts_campaign_id_fk"
  add_index "impression_counts", ["creative_id"], :name => "impression_counts_creative_id_fk"
  add_index "impression_counts", ["geography_id"], :name => "impression_counts_geography_id_fk"

  create_table "insertion_orders", :force => true do |t|
    t.string  "description"
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

  create_table "msas", :force => true do |t|
    t.string "msa_code", :null => false
    t.string "name"
  end

  create_table "msas_regions", :id => false, :force => true do |t|
    t.integer "msa_id",    :null => false
    t.integer "region_id", :null => false
  end

  add_index "msas_regions", ["msa_id"], :name => "msas_regions_msa_id_fk"
  add_index "msas_regions", ["region_id"], :name => "msas_regions_region_id_fk"

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
    t.integer  "pid"
  end

  create_table "partners", :force => true do |t|
    t.string  "name"
    t.integer "partner_code", :null => false
  end

  create_table "regions", :force => true do |t|
    t.string  "region_code", :null => false
    t.integer "country_id",  :null => false
  end

  add_index "regions", ["country_id"], :name => "regions_country_id_fk"

  create_table "regions_zips", :id => false, :force => true do |t|
    t.integer "region_id", :null => false
    t.integer "zip_id",    :null => false
  end

  add_index "regions_zips", ["region_id"], :name => "regions_zips_region_id_fk"
  add_index "regions_zips", ["zip_id"], :name => "regions_zips_zip_id_fk"

  create_table "remote_placements", :id => false, :force => true do |t|
    t.integer  "campaign_id",            :null => false
    t.integer  "geography_id"
    t.integer  "audience_id",            :null => false
    t.integer  "remote_placement_count", :null => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "duration_in_minutes"
  end

  add_index "remote_placements", ["audience_id"], :name => "remote_placements_audience_id_fk"
  add_index "remote_placements", ["campaign_id"], :name => "remote_placements_campaign_id_fk"
  add_index "remote_placements", ["geography_id"], :name => "remote_placements_geography_id_fk"

  create_table "seed_extractions", :force => true do |t|
    t.string "description"
    t.string "mapper"
    t.string "reducer"
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

  create_table "zips", :force => true do |t|
    t.string "zip_code", :null => false
  end

  add_foreign_key "ad_inventory_sources_campaigns", "ad_inventory_sources", :name => "ad_inventory_sources_campaigns_ad_inventory_source_id_fk"
  add_foreign_key "ad_inventory_sources_campaigns", "campaigns", :name => "ad_inventory_sources_campaigns_campaign_id_fk"

  add_foreign_key "audiences_campaigns", "audiences", :name => "audiences_campaigns_audience_id_fk"
  add_foreign_key "audiences_campaigns", "campaigns", :name => "audiences_campaigns_campaign_id_fk"

  add_foreign_key "campaigns", "partners", :name => "campaigns_partner_id_fk"

  add_foreign_key "campaigns_geographies", "campaigns", :name => "campaigns_geographies_campaign_id_fk"
  add_foreign_key "campaigns_geographies", "geographies", :name => "campaigns_geographies_geography_id_fk"

  add_foreign_key "cities", "regions", :name => "cities_region_id_fk"

  add_foreign_key "click_counts", "ad_inventory_sources", :name => "click_counts_ad_inventory_source_id_fk"
  add_foreign_key "click_counts", "audiences", :name => "click_counts_audience_id_fk"
  add_foreign_key "click_counts", "campaigns", :name => "click_counts_campaign_id_fk"
  add_foreign_key "click_counts", "creatives", :name => "click_counts_creative_id_fk"
  add_foreign_key "click_counts", "geographies", :name => "click_counts_geography_id_fk"

  add_foreign_key "creatives", "creative_sizes", :name => "creatives_creative_size_id_fk"

  add_foreign_key "custom_filters_line_items", "custom_filters", :name => "custom_filters_line_items_custom_filter_id_fk"
  add_foreign_key "custom_filters_line_items", "line_items", :name => "custom_filters_line_items_line_item_id_fk"

  add_foreign_key "data_provider_channels", "data_providers", :name => "data_provider_channels_data_provider_id_fk"

  add_foreign_key "data_provider_files", "data_provider_channels", :name => "data_provider_files_data_provider_channel_id_fk"

  add_foreign_key "geographies", "countries", :name => "geographies_country_id_fk"
  add_foreign_key "geographies", "msas", :name => "geographies_msa_id_fk"
  add_foreign_key "geographies", "regions", :name => "geographies_region_id_fk"
  add_foreign_key "geographies", "zips", :name => "geographies_zip_id_fk"

  add_foreign_key "impression_counts", "ad_inventory_sources", :name => "impression_counts_ad_inventory_source_id_fk"
  add_foreign_key "impression_counts", "audiences", :name => "impression_counts_audience_id_fk"
  add_foreign_key "impression_counts", "campaigns", :name => "impression_counts_campaign_id_fk"
  add_foreign_key "impression_counts", "creatives", :name => "impression_counts_creative_id_fk"
  add_foreign_key "impression_counts", "geographies", :name => "impression_counts_geography_id_fk"

  add_foreign_key "insertion_orders", "campaigns", :name => "insertion_orders_campaign_id_fk"

  add_foreign_key "msas_regions", "msas", :name => "msas_regions_msa_id_fk"
  add_foreign_key "msas_regions", "regions", :name => "msas_regions_region_id_fk"

  add_foreign_key "regions", "countries", :name => "regions_country_id_fk"

  add_foreign_key "regions_zips", "regions", :name => "regions_zips_region_id_fk"
  add_foreign_key "regions_zips", "zips", :name => "regions_zips_zip_id_fk"

  add_foreign_key "remote_placements", "audiences", :name => "remote_placements_audience_id_fk"
  add_foreign_key "remote_placements", "campaigns", :name => "remote_placements_campaign_id_fk"
  add_foreign_key "remote_placements", "geographies", :name => "remote_placements_geography_id_fk"

end
