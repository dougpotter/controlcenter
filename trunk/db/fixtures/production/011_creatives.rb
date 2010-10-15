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
},

  # Roku 4.0 seeds
  {
  :creative_code => "16122:728v2",
  :creative_size => CreativeSize.find_by_height_and_width(728,90),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ] )
},
  {
  :creative_code => "16122:300v2",
  :creative_size => CreativeSize.find_by_height_and_width(300,250),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ] )
},
  {
  :creative_code => "16122:728v2",
  :creative_size => CreativeSize.find_by_height_and_width(728,90),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ] )
},
  {
  :creative_code => "16122:300v2",
  :creative_size => CreativeSize.find_by_height_and_width(300,250),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ] )
},
  {
  :creative_code => "16122:728v5",
  :creative_size => CreativeSize.find_by_height_and_width(728,90),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "UCCO" ] ] )
},
  {
  :creative_code => "16122:300v5",
  :creative_size => CreativeSize.find_by_height_and_width(300,250),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "UCCO" ] ] )
},
  {
  :creative_code => "16122:728v2",
  :creative_size => CreativeSize.find_by_height_and_width(728,90),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ] )
},
  {
  :creative_code => "16122:300v2",
  :creative_size => CreativeSize.find_by_height_and_width(300,250),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ] )
},
  {
  :creative_code => "16122:728v2",
  :creative_size => CreativeSize.find_by_height_and_width(728,90),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ] )
},
  {
  :creative_code => "16122:300v2",
  :creative_size => CreativeSize.find_by_height_and_width(300,250),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ] )
},
  {
  :creative_code => "16122:728v5",
  :creative_size => CreativeSize.find_by_height_and_width(728,90),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "UCCO" ] ] )
},
  {
  :creative_code => "16122:300v5",
  :creative_size => CreativeSize.find_by_height_and_width(300,250),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "UCCO" ] ] )
},
  {
  :creative_code => "16122:728v2",
  :creative_size => CreativeSize.find_by_height_and_width(728,90),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ] )
},
  {
  :creative_code => "16122:300v2",
  :creative_size => CreativeSize.find_by_height_and_width(300,250),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ] )
},
  {
  :creative_code => "16122:728v2",
  :creative_size => CreativeSize.find_by_height_and_width(728,90),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ] )
},
  {
  :creative_code => "16122:300v2",
  :creative_size => CreativeSize.find_by_height_and_width(300,250),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "F50B" ] ] )
},
  {
  :creative_code => "16122:728v5",
  :creative_size => CreativeSize.find_by_height_and_width(728,90),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "UCCO" ] ] )
},
  {
  :creative_code => "16122:300v5",
  :creative_size => CreativeSize.find_by_height_and_width(300,250),
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "UCCO" ] ] )
},
{
  :description => "august creatives for wisc",
  :media_type => "static gif",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 300,
    :width => 250
  }),
  :creative_code => "300-g-wisc",
  :file_name => "300x250.gif",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "august creatives for wisc",
  :media_type => "flash",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 300,
    :width => 250
  }),
  :creative_code => "300-f-wisc-1",
  :file_name => "300x250_1.swf",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "august creatives for wisc",
  :media_type => "flash",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 300,
    :width => 250
  }),
  :creative_code => "300-f-wisc-2",
  :file_name => "300x250_2.swf",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "august creatives for wisc",
  :media_type => "flash",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 300,
    :width => 250
  }),
  :creative_code => "300-f-wisc-3",
  :file_name => "300x250_3.swf",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "august creatives for wisc",
  :media_type => "static gif",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 728,
    :width => 90
  }),
  :creative_code => "728-g-wisc",
  :file_name => "728x90.gif",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "august creatives for wisc",
  :media_type => "flash",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 728,
    :width => 90
  }),
  :creative_code => "728-f-wisc-1",
  :file_name => "728x90_1.swf",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "august creatives for wisc",
  :media_type => "flash",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 728,
    :width => 90
  }),
  :creative_code => "728-f-wisc-2",
  :file_name => "728x90_2.swf",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "august creatives for wisc",
  :media_type => "flash",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 728,
    :width => 90
  }),
  :creative_code => "728-f-wisc-3",
  :file_name => "728x90_3.swf",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "sept creatives for wisc",
  :media_type => "static gif",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 728,
    :width => 90
  }),
  :creative_code => "728-g-wav-r",
  :file_name => "728x90-WAV-red.gif",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "sept creatives for wisc",
  :media_type => "static gif",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 728,
    :width => 90
  }),
  :creative_code => "728-g-wav-b",
  :file_name => "728x90-WAV-blue.gif",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "sept creatives for wisc",
  :media_type => "static gif",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 300,
    :width => 250
  }),
  :creative_code => "300-g-wav-r",
  :file_name => "300x250-WAV-red.gif",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "sept creatives for wisc",
  :media_type => "static gif",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 300,
    :width => 250
  }),
  :creative_code => "300-g-wav-b",
  :file_name => "300x250-WAV-blue.gif",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "sept creatives for wisc",
  :media_type => "static gif",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 160,
    :width => 600
  }),
  :creative_code => "160-g-wav-r",
  :file_name => "160x600-WAV-red.gif",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
},
{
  :description => "sept creatives for wisc",
  :media_type => "static gif",
  :creative_size => CreativeSize.find(:first, :conditions => {
    :height => 160,
    :width => 600
  }),
  :creative_code => "160-g-wav-b",
  :file_name => "160x600-WAV-blue.gif",
  :campaigns => Campaign.find(:all, :conditions => ["campaign_code IN (?)", [ "EUYZ" ] ] )
}
])
