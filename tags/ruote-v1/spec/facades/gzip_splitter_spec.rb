#!/usr/bin/env ruby

# Run me with:
#
# spec spec/facades/gzip_splitter_spec.rb
#
# from rails root. Won't work from other directories (correctly)
# since we don't depend on environment to figure out rails root.

$: << 'app/facades'

require "rubygems"
require "spec"
require 'zlib'
require 'stringio'
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

describe GzipSplitter do
  def files_root
    "./tmp/test"
  end
  
  before(:all) do
    FileUtils.mkdir_p(files_root)
  end
  
  def create_subdir(subdir)
    FileUtils.rm_rf(subdir)
    FileUtils.mkdir_p(subdir)
  end
  
  def write_file(path, content)
    File.open(path, 'wb') do |f|
      f << content
    end
  end
  
  def read_file(path)
    File.read(path)
  end
  
  def list_files(path)
    # fixme
    Dir["#{path}/*"]
  end
  
  def compress(content)
    buffer = StringIO.new
    gz = Zlib::GzipWriter.new(buffer)
    gz << content
    gz.close
    buffer.string
  end
  
  def decompress(content)
    gz = Zlib::GzipReader.new(StringIO.new(content))
    content = gz.read
    gz.close
    content
  end
  
  before(:each) do
    @gzip_splitter = GzipSplitter.new
  end
  
  def test_with_two(test_name, one_content, two_content)
    subdir = "#{files_root}/#{test_name}"
    create_subdir(subdir)
    content = compress(one_content)
    content += compress(two_content)
    write_file(compressed_path = "#{subdir}/compressed.gz", content)
    
    FileUtils.mkdir_p(output_dir = "#{subdir}/output")
    @gzip_splitter.transform(compressed_path, output_dir, 'file%d.gz')
    
    file_list = list_files(output_dir).sort
    file_list.length.should == 2
    first_content = decompress(read_file(file_list[0]))
    first_content.should == one_content
    
    second_content = decompress(read_file(file_list[1]))
    second_content.should == two_content
  end
  
  it 'should be able to split one file into two' do
    test_with_two('one_two', "one\n", "two\n")
  end
  
  it 'should be able to split one file into two when both files are big' do
    test_with_two('one_two_big', "one\n" * 10000, "two\n" * 10000)
  end
  
  it 'should be able to split one file into two when both files are big and compress to substantial size' do
    one_content = read_file('/bin/sh')
    two_content = read_file('/usr/bin/ld')
    test_with_two('one_two_really_big', one_content, two_content)
  end
end
