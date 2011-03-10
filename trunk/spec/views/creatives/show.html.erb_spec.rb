require 'spec_helper'

describe "creatives/show.html.erb" do
  it "should render" do
    image = mock(
      "image",
      :url => "http://apath"
    )
    creative_size = mock(
      "creative_size",
      :height_width_string => "widthXheight"
    )
    ais = mock(
      "ais",
      :name => "ais name"
    )
    ais.expects(:ais_code).times(3).returns("ACODE", "ACODE", "ACODE")
    caic = mock(
      "campaign_inventory_config",
      :ad_inventory_source => ais
    )
    campaign = mock(
      "campaign",
      :name => "campaign name",
      :campaign_inventory_configs => [ caic ],
      :campaign_code_and_description => "ACODE - description"
    )
    creative = mock(
      "creative",
      :name => "creative name",
      :image => image,
      :creative_code => "ACODE",
      :media_type => "type_of_media",
      :creative_size => creative_size,
      :configured? => true
    )
    creative.expects(:campaigns).twice.returns([ campaign])
    creative.expects(:ae_pixels).times(3).returns(
      "http://pixel", 
      "http://pixel",
      "http://pixel"
    )
    assigns[:creative] = creative
    render
  end
end
