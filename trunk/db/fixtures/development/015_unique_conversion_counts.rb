UniqueConversionCount.seed_many([
  { :campaign_id => 1, :start_time => "2010-08-25 01:00:00", :end_time => "2010-08-25 02:00:00", :duration_in_minutes => 60, :unique_conversion_count => 1000 },
  { :campaign_id => 1, :start_time => "2010-08-25 02:00:00", :end_time => "2010-08-25 03:00:00", :duration_in_minutes => 60, :unique_conversion_count => 900},
  { :campaign_id => 1, :start_time => "2010-08-25 03:00:00", :end_time => "2010-08-25 04:00:00", :duration_in_minutes => 60, :unique_conversion_count => 800},
  { :campaign_id => 1, :start_time => "2010-08-25 00:00:00", :end_time => "2010-08-26 00:00:00", :duration_in_minutes => 1440, :unique_conversion_count => 1500},
  { :campaign_id => 2, :start_time => "2010-08-25 00:00:00", :end_time => "2010-08-25 01:00:00", :duration_in_minutes => 60, :unique_conversion_count => 200},
  { :campaign_id => 2, :start_time => "2010-08-25 01:00:00", :end_time => "2010-08-25 02:00:00", :duration_in_minutes => 60, :unique_conversion_count => 300},
  { :campaign_id => 2, :start_time => "2010-08-29 00:00:00", :end_time => "2010-08-30 00:00:00", :duration_in_minutes => 1440, :unique_conversion_count => 1100},
  { :campaign_id => 3, :start_time => "2010-08-28 00:00:00", :end_time => "2010-08-29 00:00:00", :duration_in_minutes => 1440, :unique_conversion_count => 4000}
])

