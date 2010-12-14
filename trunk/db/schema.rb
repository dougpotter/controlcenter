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

ActiveRecord::Schema.define(:version => 20101214210308) do

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

  create_table "campaigns_creatives", :id => false, :force => true do |t|
    t.integer "campaign_id", :null => false
    t.integer "creative_id", :null => false
  end

  add_index "campaigns_creatives", ["campaign_id"], :name => "campaigns_creatives_campaign_id_fk"
  add_index "campaigns_creatives", ["creative_id"], :name => "campaigns_creatives_creative_id_fk"

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

  create_table "click_counts", :force => true do |t|
    t.integer  "campaign_id",              :null => false
    t.integer  "creative_id",              :null => false
    t.integer  "ad_inventory_source_id",   :null => false
    t.integer  "geography_id"
    t.integer  "audience_id",              :null => false
    t.integer  "click_count",              :null => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "duration_in_minutes"
    t.integer  "media_purchase_method_id"
  end

  add_index "click_counts", ["ad_inventory_source_id"], :name => "click_counts_ad_inventory_source_id_fk"
  add_index "click_counts", ["audience_id"], :name => "click_counts_audience_id_fk"
  add_index "click_counts", ["campaign_id", "creative_id", "ad_inventory_source_id", "audience_id", "media_purchase_method_id", "start_time", "end_time", "duration_in_minutes"], :name => "click_counts_required_columns_20100827", :unique => true
  add_index "click_counts", ["campaign_id"], :name => "click_counts_campaign_id_fk"
  add_index "click_counts", ["creative_id"], :name => "click_counts_creative_id_fk"
  add_index "click_counts", ["geography_id"], :name => "click_counts_geography_id_fk"
  add_index "click_counts", ["media_purchase_method_id"], :name => "click_counts_media_purchase_method_id_fk"

  create_table "click_through_rates", :force => true do |t|
    t.integer  "campaign_id"
    t.integer  "ad_inventory_source_id"
    t.integer  "media_purchase_method_id"
    t.integer  "audience_id"
    t.integer  "creative_id"
    t.datetime "start_time",               :null => false
    t.datetime "end_time",                 :null => false
    t.integer  "duration_in_minutes",      :null => false
    t.float    "click_through_rate",       :null => false
  end

  add_index "click_through_rates", ["ad_inventory_source_id"], :name => "click_through_rates_ad_inventory_source_id_fk"
  add_index "click_through_rates", ["audience_id"], :name => "click_through_rates_audience_id_fk"
  add_index "click_through_rates", ["campaign_id", "ad_inventory_source_id", "media_purchase_method_id", "audience_id", "creative_id", "start_time", "end_time", "duration_in_minutes"], :name => "click_through_rates_required_columns", :unique => true
  add_index "click_through_rates", ["creative_id"], :name => "click_through_rates_creative_id_fk"
  add_index "click_through_rates", ["media_purchase_method_id"], :name => "click_through_rates_media_purchase_method_id_fk"

  create_table "conversion_counts", :force => true do |t|
    t.integer  "campaign_id",         :null => false
    t.datetime "start_time",          :null => false
    t.datetime "end_time",            :null => false
    t.integer  "duration_in_minutes", :null => false
    t.integer  "conversion_count",    :null => false
  end

  add_index "conversion_counts", ["campaign_id"], :name => "conversion_counts_campaign_id_fk"

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
    t.string   "name"
    t.string   "media_type"
    t.integer  "creative_size_id",   :null => false
    t.string   "creative_code",      :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "creatives", ["creative_code"], :name => "index_creatives_on_creative_code", :unique => true
  add_index "creatives", ["creative_size_id"], :name => "creatives_creative_size_id_fk"

  create_table "data_provider_channels", :force => true do |t|
    t.integer "data_provider_id",   :null => false
    t.string  "name",               :null => false
    t.integer "update_frequency"
    t.integer "lookback_from_hour", :null => false
    t.integer "lookback_to_hour",   :null => false
  end

  add_index "data_provider_channels", ["data_provider_id"], :name => "data_provider_channels_data_provider_id_fk"

  create_table "data_provider_files", :force => true do |t|
    t.integer  "data_provider_channel_id", :null => false
    t.string   "url",                      :null => false
    t.integer  "status",                   :null => false
    t.datetime "discovered_at"
    t.datetime "extracted_at"
    t.datetime "verified_at"
    t.date     "label_date"
    t.integer  "label_hour"
  end

  add_index "data_provider_files", ["data_provider_channel_id", "url"], :name => "index_data_provider_files_on_data_provider_channel_id_and_url", :unique => true
  add_index "data_provider_files", ["data_provider_channel_id"], :name => "data_provider_files_data_provider_channel_id_fk"

  create_table "data_providers", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "ecpas", :force => true do |t|
    t.integer  "campaign_id"
    t.integer  "ad_inventory_source_id"
    t.integer  "media_purchase_method_id"
    t.integer  "audience_id"
    t.integer  "creative_id"
    t.datetime "start_time",               :null => false
    t.datetime "end_time",                 :null => false
    t.integer  "duration_in_minutes",      :null => false
    t.float    "ecpa",                     :null => false
  end

  add_index "ecpas", ["ad_inventory_source_id"], :name => "ecpas_ad_inventory_source_id_fk"
  add_index "ecpas", ["audience_id"], :name => "ecpas_audience_id_fk"
  add_index "ecpas", ["campaign_id", "ad_inventory_source_id", "media_purchase_method_id", "audience_id", "creative_id"], :name => "ecpas_required_columns", :unique => true
  add_index "ecpas", ["creative_id"], :name => "ecpas_creative_id_fk"
  add_index "ecpas", ["media_purchase_method_id"], :name => "ecpas_media_purchase_method_id_fk"

  create_table "ecpcs", :force => true do |t|
    t.integer  "campaign_id"
    t.integer  "ad_inventory_source_id"
    t.integer  "media_purchase_method_id"
    t.integer  "audience_id"
    t.integer  "creative_id"
    t.datetime "start_time",               :null => false
    t.datetime "end_time",                 :null => false
    t.integer  "duration_in_minutes",      :null => false
    t.float    "ecpc",                     :null => false
  end

  add_index "ecpcs", ["ad_inventory_source_id"], :name => "ecpcs_ad_inventory_source_id_fk"
  add_index "ecpcs", ["audience_id"], :name => "ecpcs_audience_id_fk"
  add_index "ecpcs", ["campaign_id", "ad_inventory_source_id", "media_purchase_method_id", "audience_id", "creative_id"], :name => "ecpcs_required_columns", :unique => true
  add_index "ecpcs", ["creative_id"], :name => "ecpcs_creative_id_fk"
  add_index "ecpcs", ["media_purchase_method_id"], :name => "ecpcs_media_purchase_method_id_fk"

  create_table "ecpms", :force => true do |t|
    t.integer  "campaign_id"
    t.integer  "ad_inventory_source_id"
    t.integer  "media_purchase_method_id"
    t.integer  "audience_id"
    t.integer  "creative_id"
    t.datetime "start_time",               :null => false
    t.datetime "end_time",                 :null => false
    t.integer  "duration_in_minutes",      :null => false
    t.float    "ecpm",                     :null => false
  end

  add_index "ecpms", ["ad_inventory_source_id"], :name => "ecpms_ad_inventory_source_id_fk"
  add_index "ecpms", ["audience_id"], :name => "ecpms_audience_id_fk"
  add_index "ecpms", ["campaign_id", "ad_inventory_source_id", "media_purchase_method_id", "audience_id", "creative_id", "start_time", "end_time", "duration_in_minutes"], :name => "ecpms_required_columns", :unique => true
  add_index "ecpms", ["creative_id"], :name => "ecpms_creative_id_fk"
  add_index "ecpms", ["media_purchase_method_id"], :name => "ecpms_media_purchase_method_id_fk"

  create_table "effective_cost_per_thousand_impressions", :force => true do |t|
    t.integer  "campaign_id"
    t.integer  "ad_inventory_source_id"
    t.integer  "media_purchase_method_id"
    t.integer  "audience_id"
    t.integer  "creative_id"
    t.datetime "start_time",               :null => false
    t.datetime "end_time",                 :null => false
    t.datetime "duration_in_minutes",      :null => false
    t.float    "ecpm",                     :null => false
  end

  add_index "effective_cost_per_thousand_impressions", ["campaign_id"], :name => "effective_cost_per_thousand_impressions_campaign_id_fk"

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

  create_table "impression_counts", :force => true do |t|
    t.integer  "campaign_id",              :null => false
    t.integer  "creative_id",              :null => false
    t.integer  "ad_inventory_source_id",   :null => false
    t.integer  "geography_id"
    t.integer  "audience_id",              :null => false
    t.integer  "impression_count",         :null => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "duration_in_minutes"
    t.integer  "media_purchase_method_id"
  end

  add_index "impression_counts", ["ad_inventory_source_id"], :name => "impression_counts_ad_inventory_source_id_fk"
  add_index "impression_counts", ["audience_id"], :name => "impression_counts_audience_id_fk"
  add_index "impression_counts", ["campaign_id", "creative_id", "ad_inventory_source_id", "audience_id", "media_purchase_method_id", "start_time", "end_time", "duration_in_minutes"], :name => "impression_counts_required_columns_20100827", :unique => true
  add_index "impression_counts", ["campaign_id"], :name => "impression_counts_campaign_id_fk"
  add_index "impression_counts", ["creative_id"], :name => "impression_counts_creative_id_fk"
  add_index "impression_counts", ["geography_id"], :name => "impression_counts_geography_id_fk"
  add_index "impression_counts", ["media_purchase_method_id"], :name => "impression_counts_media_purchase_method_id_fk"

  create_table "line_items", :force => true do |t|
    t.integer "impressions"
    t.float   "internal_pricing"
    t.float   "external_pricing"
    t.integer "insertion_order_id"
  end

  create_table "media_costs", :force => true do |t|
    t.integer  "partner_id",               :null => false
    t.integer  "campaign_id",              :null => false
    t.integer  "media_purchase_method_id", :null => false
    t.integer  "audience_id",              :null => false
    t.integer  "creative_id",              :null => false
    t.datetime "start_time",               :null => false
    t.datetime "end_time",                 :null => false
    t.integer  "duration_in_minutes",      :null => false
    t.float    "media_cost",               :null => false
  end

  add_index "media_costs", ["audience_id"], :name => "media_costs_audience_id_fk"
  add_index "media_costs", ["campaign_id"], :name => "media_costs_campaign_id_fk"
  add_index "media_costs", ["creative_id"], :name => "media_costs_creative_id_fk"
  add_index "media_costs", ["media_purchase_method_id"], :name => "media_costs_media_purchase_method_id_fk"
  add_index "media_costs", ["partner_id"], :name => "media_costs_partner_id_fk"

  create_table "media_purchase_methods", :force => true do |t|
    t.string "mpm_code"
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

  create_table "remote_placements", :force => true do |t|
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

  create_table "unique_click_counts", :force => true do |t|
    t.integer  "partner_id"
    t.integer  "campaign_id"
    t.integer  "media_purchase_method_id"
    t.integer  "audience_id"
    t.integer  "creative_id"
    t.datetime "start_time",               :null => false
    t.datetime "end_time",                 :null => false
    t.integer  "duration_in_minutes",      :null => false
    t.integer  "unique_click_count",       :null => false
  end

  add_index "unique_click_counts", ["audience_id"], :name => "unique_click_counts_audience_id_fk"
  add_index "unique_click_counts", ["campaign_id"], :name => "unique_click_counts_campaign_id_fk"
  add_index "unique_click_counts", ["creative_id"], :name => "unique_click_counts_creative_id_fk"
  add_index "unique_click_counts", ["media_purchase_method_id"], :name => "unique_click_counts_media_purchase_method_id_fk"
  add_index "unique_click_counts", ["partner_id"], :name => "unique_click_counts_partner_id_fk"

  create_table "unique_conversion_counts", :force => true do |t|
    t.integer  "campaign_id"
    t.datetime "start_time",              :null => false
    t.datetime "end_time",                :null => false
    t.integer  "duration_in_minutes",     :null => false
    t.integer  "unique_conversion_count", :null => false
  end

  add_index "unique_conversion_counts", ["campaign_id"], :name => "unique_conversion_counts_campaign_id_fk"

  create_table "unique_fact_meta_datas", :force => true do |t|
    t.text    "interest_specification"
    t.integer "unique_fact_id"
    t.string  "unique_fact_type"
  end

  create_table "unique_impression_counts", :force => true do |t|
    t.integer  "partner_id"
    t.integer  "campaign_id"
    t.integer  "media_purchase_method_id"
    t.integer  "audience_id"
    t.integer  "creative_id"
    t.datetime "start_time",               :null => false
    t.datetime "end_time",                 :null => false
    t.integer  "duration_in_minutes",      :null => false
    t.integer  "unique_impression_count",  :null => false
  end

  add_index "unique_impression_counts", ["audience_id"], :name => "unique_impression_counts_audience_id_fk"
  add_index "unique_impression_counts", ["campaign_id"], :name => "unique_impression_counts_campaign_id_fk"
  add_index "unique_impression_counts", ["creative_id"], :name => "unique_impression_counts_creative_id_fk"
  add_index "unique_impression_counts", ["media_purchase_method_id"], :name => "unique_impression_counts_media_purchase_method_id_fk"
  add_index "unique_impression_counts", ["partner_id"], :name => "unique_impression_counts_partner_id_fk"

  create_table "unique_remote_placement_counts", :force => true do |t|
    t.integer  "audience_id"
    t.datetime "start_time",                    :null => false
    t.datetime "end_time",                      :null => false
    t.integer  "duration_in_minutes",           :null => false
    t.integer  "unique_remote_placement_count", :null => false
  end

  add_index "unique_remote_placement_counts", ["audience_id"], :name => "unique_remote_placement_counts_audience_id_fk"

  create_table "unique_view_through_conversion_counts", :force => true do |t|
    t.integer  "campaign_id"
    t.integer  "ad_inventory_source_id"
    t.integer  "audience_id"
    t.integer  "creative_id"
    t.datetime "start_time",                           :null => false
    t.datetime "end_time",                             :null => false
    t.integer  "duration_in_minutes"
    t.integer  "unique_view_through_conversion_count", :null => false
  end

  add_index "unique_view_through_conversion_counts", ["ad_inventory_source_id"], :name => "unique_view_through_counts_ad_inventory_source_id_fk"
  add_index "unique_view_through_conversion_counts", ["audience_id"], :name => "unique_view_through_counts_audience_id_fk"
  add_index "unique_view_through_conversion_counts", ["campaign_id"], :name => "unique_view_through_counts_campaign_id_fk"
  add_index "unique_view_through_conversion_counts", ["creative_id"], :name => "unique_view_through_counts_creative_id_fk"

  create_table "zips", :force => true do |t|
    t.string "zip_code", :null => false
  end

  add_foreign_key "ad_inventory_sources_campaigns", "ad_inventory_sources", :name => "ad_inventory_sources_campaigns_ad_inventory_source_id_fk"
  add_foreign_key "ad_inventory_sources_campaigns", "campaigns", :name => "ad_inventory_sources_campaigns_campaign_id_fk"

  add_foreign_key "audiences_campaigns", "audiences", :name => "audiences_campaigns_audience_id_fk"
  add_foreign_key "audiences_campaigns", "campaigns", :name => "audiences_campaigns_campaign_id_fk"

  add_foreign_key "campaigns", "partners", :name => "campaigns_partner_id_fk"

  add_foreign_key "campaigns_creatives", "campaigns", :name => "campaigns_creatives_campaign_id_fk"
  add_foreign_key "campaigns_creatives", "creatives", :name => "campaigns_creatives_creative_id_fk"

  add_foreign_key "campaigns_geographies", "campaigns", :name => "campaigns_geographies_campaign_id_fk"
  add_foreign_key "campaigns_geographies", "geographies", :name => "campaigns_geographies_geography_id_fk"

  add_foreign_key "cities", "regions", :name => "cities_region_id_fk"

  add_foreign_key "click_counts", "ad_inventory_sources", :name => "click_counts_ad_inventory_source_id_fk"
  add_foreign_key "click_counts", "audiences", :name => "click_counts_audience_id_fk"
  add_foreign_key "click_counts", "campaigns", :name => "click_counts_campaign_id_fk"
  add_foreign_key "click_counts", "creatives", :name => "click_counts_creative_id_fk"
  add_foreign_key "click_counts", "geographies", :name => "click_counts_geography_id_fk"
  add_foreign_key "click_counts", "media_purchase_methods", :name => "click_counts_media_purchase_method_id_fk"

  add_foreign_key "click_through_rates", "ad_inventory_sources", :name => "click_through_rates_ad_inventory_source_id_fk"
  add_foreign_key "click_through_rates", "audiences", :name => "click_through_rates_audience_id_fk"
  add_foreign_key "click_through_rates", "campaigns", :name => "click_through_rates_campaign_id_fk"
  add_foreign_key "click_through_rates", "creatives", :name => "click_through_rates_creative_id_fk"
  add_foreign_key "click_through_rates", "media_purchase_methods", :name => "click_through_rates_media_purchase_method_id_fk"

  add_foreign_key "conversion_counts", "campaigns", :name => "conversion_counts_campaign_id_fk"

  add_foreign_key "creatives", "creative_sizes", :name => "creatives_creative_size_id_fk"

  add_foreign_key "data_provider_channels", "data_providers", :name => "data_provider_channels_data_provider_id_fk"

  add_foreign_key "data_provider_files", "data_provider_channels", :name => "data_provider_files_data_provider_channel_id_fk"

  add_foreign_key "ecpas", "ad_inventory_sources", :name => "ecpas_ad_inventory_source_id_fk"
  add_foreign_key "ecpas", "audiences", :name => "ecpas_audience_id_fk"
  add_foreign_key "ecpas", "campaigns", :name => "ecpas_campaign_id_fk"
  add_foreign_key "ecpas", "creatives", :name => "ecpas_creative_id_fk"
  add_foreign_key "ecpas", "media_purchase_methods", :name => "ecpas_media_purchase_method_id_fk"

  add_foreign_key "ecpcs", "ad_inventory_sources", :name => "ecpcs_ad_inventory_source_id_fk"
  add_foreign_key "ecpcs", "audiences", :name => "ecpcs_audience_id_fk"
  add_foreign_key "ecpcs", "campaigns", :name => "ecpcs_campaign_id_fk"
  add_foreign_key "ecpcs", "creatives", :name => "ecpcs_creative_id_fk"
  add_foreign_key "ecpcs", "media_purchase_methods", :name => "ecpcs_media_purchase_method_id_fk"

  add_foreign_key "ecpms", "ad_inventory_sources", :name => "ecpms_ad_inventory_source_id_fk"
  add_foreign_key "ecpms", "audiences", :name => "ecpms_audience_id_fk"
  add_foreign_key "ecpms", "campaigns", :name => "ecpms_campaign_id_fk"
  add_foreign_key "ecpms", "creatives", :name => "ecpms_creative_id_fk"
  add_foreign_key "ecpms", "media_purchase_methods", :name => "ecpms_media_purchase_method_id_fk"

  add_foreign_key "effective_cost_per_thousand_impressions", "campaigns", :name => "effective_cost_per_thousand_impressions_campaign_id_fk"

  add_foreign_key "geographies", "countries", :name => "geographies_country_id_fk"
  add_foreign_key "geographies", "msas", :name => "geographies_msa_id_fk"
  add_foreign_key "geographies", "regions", :name => "geographies_region_id_fk"
  add_foreign_key "geographies", "zips", :name => "geographies_zip_id_fk"

  add_foreign_key "impression_counts", "ad_inventory_sources", :name => "impression_counts_ad_inventory_source_id_fk"
  add_foreign_key "impression_counts", "audiences", :name => "impression_counts_audience_id_fk"
  add_foreign_key "impression_counts", "campaigns", :name => "impression_counts_campaign_id_fk"
  add_foreign_key "impression_counts", "creatives", :name => "impression_counts_creative_id_fk"
  add_foreign_key "impression_counts", "geographies", :name => "impression_counts_geography_id_fk"
  add_foreign_key "impression_counts", "media_purchase_methods", :name => "impression_counts_media_purchase_method_id_fk"

  add_foreign_key "media_costs", "audiences", :name => "media_costs_audience_id_fk"
  add_foreign_key "media_costs", "campaigns", :name => "media_costs_campaign_id_fk"
  add_foreign_key "media_costs", "creatives", :name => "media_costs_creative_id_fk"
  add_foreign_key "media_costs", "media_purchase_methods", :name => "media_costs_media_purchase_method_id_fk"
  add_foreign_key "media_costs", "partners", :name => "media_costs_partner_id_fk"

  add_foreign_key "msas_regions", "msas", :name => "msas_regions_msa_id_fk"
  add_foreign_key "msas_regions", "regions", :name => "msas_regions_region_id_fk"

  add_foreign_key "regions", "countries", :name => "regions_country_id_fk"

  add_foreign_key "regions_zips", "regions", :name => "regions_zips_region_id_fk"
  add_foreign_key "regions_zips", "zips", :name => "regions_zips_zip_id_fk"

  add_foreign_key "remote_placements", "audiences", :name => "remote_placements_audience_id_fk"
  add_foreign_key "remote_placements", "campaigns", :name => "remote_placements_campaign_id_fk"
  add_foreign_key "remote_placements", "geographies", :name => "remote_placements_geography_id_fk"

  add_foreign_key "unique_click_counts", "audiences", :name => "unique_click_counts_audience_id_fk"
  add_foreign_key "unique_click_counts", "campaigns", :name => "unique_click_counts_campaign_id_fk"
  add_foreign_key "unique_click_counts", "creatives", :name => "unique_click_counts_creative_id_fk"
  add_foreign_key "unique_click_counts", "media_purchase_methods", :name => "unique_click_counts_media_purchase_method_id_fk"
  add_foreign_key "unique_click_counts", "partners", :name => "unique_click_counts_partner_id_fk"

  add_foreign_key "unique_conversion_counts", "campaigns", :name => "unique_conversion_counts_campaign_id_fk"

  add_foreign_key "unique_impression_counts", "audiences", :name => "unique_impression_counts_audience_id_fk"
  add_foreign_key "unique_impression_counts", "campaigns", :name => "unique_impression_counts_campaign_id_fk"
  add_foreign_key "unique_impression_counts", "creatives", :name => "unique_impression_counts_creative_id_fk"
  add_foreign_key "unique_impression_counts", "media_purchase_methods", :name => "unique_impression_counts_media_purchase_method_id_fk"
  add_foreign_key "unique_impression_counts", "partners", :name => "unique_impression_counts_partner_id_fk"

  add_foreign_key "unique_remote_placement_counts", "audiences", :name => "unique_remote_placement_counts_audience_id_fk"

  add_foreign_key "unique_view_through_conversion_counts", "ad_inventory_sources", :name => "unique_view_through_counts_ad_inventory_source_id_fk"
  add_foreign_key "unique_view_through_conversion_counts", "audiences", :name => "unique_view_through_counts_audience_id_fk"
  add_foreign_key "unique_view_through_conversion_counts", "campaigns", :name => "unique_view_through_counts_campaign_id_fk"
  add_foreign_key "unique_view_through_conversion_counts", "creatives", :name => "unique_view_through_counts_creative_id_fk"

end
