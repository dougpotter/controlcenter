class SegmentPixel < ActiveRecord::Base
  has_no_table

  column :pixel_code, :string
  column :name, :string
  column :partner_code, :string
  column :partner_id, :string
  column :member_id, :string
  column :apn_id, :string

  acts_as_apn_object :apn_attr_map => {
    :code => "pixel_code",
    :short_name => "name",
    :advertiser_code => "partner_code" },
    :non_method_attr_map => {
      :member_id => APN_CONFIG["member_id"],
      :status => "inactive" },
    :apn_wrapper => "segment",
    :urls => {
      # this should work (based on ApN API conventions), but it doesn't. I put in
      # a request to have it implemented
      #:new => "segment?advertiser_code=##partner_code##",
      :new => "segment?advertiser_id=##partner_id##",
      :view => "segment?code=##pixel_code##",
      :view_by_id => "segment?id=##apn_id##",
      :update => "segment?code=##pixel_code##",
      :update_by_id => "segment?id=##apn_id##",
      :delete => "segment?code=##pixel_code##",
      :delete_by_apn_ids => "segment?id=##apn_id##",
      :index => "segment" }
end
