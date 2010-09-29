require 'spec_helper'

describe "/facts/index.csv" do
  # A basic functionality test.
  it "should produce a valid csv file" do
    assigns[:csv_rows] = [
      ['date', 'count'],
      ['2010-01-01', '42'],
    ]
    
    render
    
    body = response.body
    
    # refactor into a matcher?
    lines = FasterCSV.parse(body)
    lines.length.should == 2
    lines.first.should == %w(date count)
    lines.last.should == %w(2010-01-01 42)
  end
end
