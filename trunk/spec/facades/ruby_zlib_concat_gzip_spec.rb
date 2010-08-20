#!/usr/bin/env ruby

# Run me with:
#
# spec spec/facades/ruby_zlib_concat_gzip_spec.rb
#
# from rails root. Won't work from other directories (correctly)
# since we don't depend on environment to figure out rails root.

require "rubygems"
require "spec"
require 'lib/zlib_shortcuts'

# Ruby's Zlib::GzipReader only sees and extracts the first member of a
# multi-member (concatenated) gzip archive.
# This test exists to document this behavior and catch if it ever changes.

describe Zlib::GzipReader do
  it "should decompress only the first part of two-file concatenated gzip archive" do
    compressed_a = ZlibShortcuts.gzip_compress('a')
    compressed_b = ZlibShortcuts.gzip_compress('b')
    compressed = compressed_a + compressed_b
    decompressed = ZlibShortcuts.gzip_decompress(compressed)
    decompressed.should == 'a'
  end
end
