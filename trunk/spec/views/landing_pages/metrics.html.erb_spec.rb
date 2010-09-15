require 'spec_helper'

describe "/landing_pages/metrics" do
  # Basic functionality test, check that the page is displayed without errors.
  it "should display a form" do
    assigns[:partners] = []
    assigns[:campaigns] = []
    assigns[:creatives] = []
    
    render
  end
end
