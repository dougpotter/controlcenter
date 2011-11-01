class ConversionPixel < ActiveRecord::Base
  has_no_table

  column :pixel_code, :string
  column :name, :string
  column :partner_code, :string

  acts_as_apn_object :apn_attr_map => {
    :code => "pixel_code",
    :name => "name",
    :advertiser_code => "partner_code" },
    :non_method_attr_map => {
      :status => "inactive" },
    :apn_wrapper => "pixel",
    :method_map => {
      :new => [ "new_pixel_by_code", "partner_code" ],
      :put => [ "update_pixel_by_code", "partner_code", "pixel_code" ],
      :view => [ "pixel_by_code", "partner_code", "pixel_code" ] }

end
