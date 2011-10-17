class ConversionPixel < ActiveRecord::Base
  has_no_table

  column :pixel_code, :string
  column :name, :string
  column :partner_code, :string
  column :partner_id, :string
  column :apn_id, :string

  acts_as_apn_object :apn_attr_map => {
    :code => "pixel_code",
    :name => "name",
    :advertiser_code => "partner_code" },
    :non_method_attr_map => {
      :status => "inactive" },
    :apn_wrapper => "pixel",
    :urls => {
      :new => "pixel?advertiser_code=##partner_code##",
      :view => "pixel?advertiser_code=##partner_code##&code=##pixel_code##",
      :view_by_id => "pixel?advertiser_id=##partner_id##&id=##apn_id##",
      :update => "pixel?advertiser_code=##partner_code##&code=##pixel_code##",
      :update_by_id => "pixel?advertiser_id=##partner_id##&id=##apn_id##",
      :delete => "pixel?advertiser_code=##partner_code##&code=##pixel_code##",
      :delete_by_apn_ids => "pixel?advertiser_id=##partner_id##&id=##apn_id##",
      :index => "pixel?advertiser_code=##partner_code##" }

end
