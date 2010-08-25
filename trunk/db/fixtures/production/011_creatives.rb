# TODO: This seed list needs to be fleshed out fully.

Creative.seed_many(:creative_code, [
  {
    :creative_code => "16122:300p",
    :creative_size => CreativeSize.find_by_height_and_width(300, 250),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "BY51" ] ]) 
  },
  {
    :creative_code => "16122:300v2",
    :creative_size => CreativeSize.find_by_height_and_width(300, 250),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "E929", "F50B" ] ]) 
  },
  {
    :creative_code => "16122:300v5",
    :creative_size => CreativeSize.find_by_height_and_width(300, 250),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "UCCO" ] ]) 
  },
  {
    :creative_code => "16122:300x600",
    :creative_size => CreativeSize.find_by_height_and_width(300, 250),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "BY51" ] ]) 
  },
  {
    :creative_code => "16122:728v2",
    :creative_size => CreativeSize.find_by_height_and_width(728, 90),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ]) 
  },
  {
    :creative_code => "16122:728v5",
    :creative_size => CreativeSize.find_by_height_and_width(728, 90),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "UCCO", "ZT4R" ] ]) 
  },
  {
    :creative_code => "16122:728v6",
    :creative_size => CreativeSize.find_by_height_and_width(728, 90),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "E929" ] ]) 
  },
  {
    :creative_code => "16122:728v8",
    :creative_size => CreativeSize.find_by_height_and_width(728, 90),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "ZT4R" ] ]) 
  },
  {
    :creative_code => "18182:160bs",
    :creative_size => CreativeSize.find_by_height_and_width(160, 600),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "D8JD", "8LM7" ] ]) 
  },
  {
    :creative_code => "18182:160ew",
    :creative_size => CreativeSize.find_by_height_and_width(160, 600),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "D8JD" ] ]) 
  },
  {
    :creative_code => "18182:300bs",
    :creative_size => CreativeSize.find_by_height_and_width(300, 250),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "D8JD", "8LM7" ] ]) 
  },
  {
    :creative_code => "18182:300ew",
    :creative_size => CreativeSize.find_by_height_and_width(300, 250),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "D8JD", "8LM7" ] ]) 
  },
  {
    :creative_code => "18182:728bs",
    :creative_size => CreativeSize.find_by_height_and_width(728, 90),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "8LM7", "D8JD" ] ]) 
  },
  {
    :creative_code => "18182:728ew",
    :creative_size => CreativeSize.find_by_height_and_width(728, 90),
    :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "8LM7", "D8JD" ] ]) 
  }
])
