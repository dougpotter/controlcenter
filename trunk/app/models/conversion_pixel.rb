class ConversionPixel < ActiveRecord::Base
  has_no_table

  column :pixel_code, :string
  column :name, :string
  column :request_regex, :string
  column :referer_regex, :string
  column :appnexus_id, :integer
  column :partner_code, :string
  column :partner_id, :integer

  acts_as_apn_object :apn_attr_map => {
    :code => "pixel_code",
    :name => "name",
    :advertiser_code => "partner_code" },
    :non_method_attr_map => {
      :status => "inactive" },
    :apn_wrapper => "pixel",
    :urls => {
      :new => "pixel?advertiser_code=##partner_code##",
      :delete_by_apn_ids => "pixel?advertiser_code=##partner_code##&id=##id##",
      :index => "pixel?advertiser_code=##partner_code##" }


  def save_beacon
    @b = Beacon.new
    new_audience_response = @b.new_audience(
      :name => self.name, 
      :active => "true",
      :audience_type => "request-conditional",
      :pid => self.partner_id
    ) 

    if new_audience_response != ''
      raise "Beacon Error: #{new_audience_response}"
    end


    # To protect against the possibility that two people are creating new partners
    # at the same time (in which case all_audiences.last would be ambiguous. This 
    # could all be eliminated if the beacon return the id of the object it just 
    # created
    audiences_descending = 
      @b.audiences.audiences.sort { |x,y| x.id <=> y.id }.reverse
    @audience_id = nil
    for audience in audiences_descending
      if audience['name'] == self.name && audience['type'] == 'request-conditional'
        @audience_id = audience.id
      end
    end

    new_request_condition_response = @b.new_request_condition(
      @audience_id, 
      :request_url_regex => self.request_regex,
      :referer_url_regex => self.referer_regex
    )

    if new_request_condition_response != ''
      raise "Beacon Error: #{new_request_condition_response}"
    else
      return true
    end
  end
end
