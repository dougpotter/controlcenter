require 'spec_helper'

describe ExtractionController do
  # Basic functionality test for index action.
  it "should generate index without errors" do
    get 'index'
    response.should be_success
  end
  
  # Requesting extraction status when no data exists for the day in question
  # should not produce errors. Use a day far in the past for checking.
  it "should not produce errors when status for a day with no data is requested" do
    date = '20000228'
    get 'status', :date => date
    response.should be_success
  end
end
