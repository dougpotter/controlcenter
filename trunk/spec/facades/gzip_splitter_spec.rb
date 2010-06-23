#!/usr/bin/env ruby

$: << 'app/facades'

require "rubygems"
require "spec"
require "gzip_splitter"

describe GzipSplitter do
  before(:each) do
    @gzip_splitter = GzipSplitter.new
  end
  
  it "should have a default value for @header_pattern" do
    @gzip_splitter.header_pattern.should == "\037\213\b\000\000"
  end

  it "should have a default value for @read_buffer_size" do
    @gzip_splitter.read_buffer_size.should == 4096
  end
end
