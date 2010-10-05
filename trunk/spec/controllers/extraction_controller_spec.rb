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
    get 'details', :date => date
    response.should be_success
  end
  
  # Since I had trouble with route generation I wrote specs for recognizing
  # all possible routes.
  describe "routing recognition" do
    it 'should recognize index route' do
      params_from(:get, '/extraction').should == {
        :controller => 'extraction', :action => 'index'
      }
    end
    
    it 'should recognize overview route' do
      params_from(:get, '/extraction/overview/2010/1').should == {
        :controller => 'extraction', :action => 'overview', :year => '2010', :month => '1'
      }
    end
    
    it 'should recognize details route' do
      params_from(:get, '/extraction/details/20100101').should == {
        :controller => 'extraction', :action => 'details', :date => '20100101'
      }
    end
  end
  
  # Since I had trouble with route generation I wrote specs for generating
  # all possible routes.
  describe 'routing generation' do
    it 'should generate index route' do
      extraction_index_path.should == '/extraction'
    end
    
    it 'should generate extraction overview route' do
      extraction_overview_path(:year => 2010, :month => 1).should == '/extraction/overview/2010/1'
    end
    
    it 'should generate extraction details route' do
      extraction_details_path(:date => '20100101').should == '/extraction/details/20100101'
    end
  end
end
