require 'spec_helper'

describe "/landing_pages/metrics" do
  # Basic functionality test, check that the page is displayed without errors.
  it "should display a form" do
    pending
    assigns[:partners] = []
    assigns[:campaigns] = []
    assigns[:creatives] = []
    assigns[:ad_inventory_sources] = []
    assigns[:audiences] = []
    assigns[:media_purchase_methods] = []
    
    render
  end
end
