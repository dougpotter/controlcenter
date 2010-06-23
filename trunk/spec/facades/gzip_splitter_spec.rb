#!/usr/bin/env ruby

$: << 'app/facades'

require "rubygems"
require "spec"
require "gzip_splitter"

describe Gzsplit do

  it "should have a default value for @header_pattern" do
    Gzsplit.new("s0400.0.log.gz",:verify => "true").header_pattern.should == "\037\213\b\000\000"
  end

  it "should have a default value for @read_buffer_size" do
    Gzsplit.new("s0400.0.log.gz",:verify => "true").read_buffer_size.should == 4096
  end

  it "should have a value for @input_file" do
    Gzsplit.new("s0400.0.log.gz",:verify => "true").input_file.should_not be_nil
  end


end

