class SegmentPixel < ActiveRecord::Base
  has_no_table

  column :pixel_code, :string
  column :name, :string
  column :partner_code, :string
  column :member_id, :string

  acts_as_apn_object :apn_attr_map => {
    :code => "pixel_code",
    :short_name => "name",
    :advertiser_code => "partner_code" },
    :non_method_attr_map => {
      :member_id => APN_CONFIG["member_id"],
      :status => "inactive" },
    :apn_wrapper => "segment",
    :method_map => {
      :view => [ "segment_by_code", "pixel_code" ],
      :put => [ "update_segment_by_code", "pixel_code" ] },
    :urls => {
      :new => "segment?advertiser_code=##partner_code##",
      :view => "segment?code=##pixel_code##",
      :update => "segment?code=##pixel_code##",
      :delete => "segment?code=##pixel_code##",
      :delete_by_apn_ids => "segment?id=##id##",
      :index => "segment" }
end
