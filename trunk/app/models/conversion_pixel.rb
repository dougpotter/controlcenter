class ConversionPixel < ActiveRecord::Base
  has_no_table

  column :name, :string
  column :request_regex, :string
  column :referrer_regex, :string
  column :appnexus_id, :integer
  column :partner_code, :string
  column :partner_id, :integer

  acts_as_apn_object :apn_attr_map => {
    :name => "name" },
    :non_method_attr_map => {
      :status => "inactive" },
    :apn_wrapper => "pixel",
    :urls => {
      :new => "pixel?advertiser_code=##partner_code##",
      :index => "pixel?advertiser_code=##partner_code##" }
end
