# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

FILTERS = {
  :FlateDecode    => {'test' => "x\x9C+I-.\x01\x00\x04]\x01\xC1".force_encoding(Encoding::ASCII_8BIT) },
  :DCTDecode      => {'test' => "test"}
}

FILTERS.each do |filter_name, examples|
  filter = PDF::Core::Filters.const_get(filter_name)

  describe "#{filter_name} filter" do
    it "should encode stream" do
      examples.each do |in_stream, out_stream|
        filter.encode(in_stream).should == out_stream
      end
    end

    it "should decode stream" do
      examples.each do |in_stream, out_stream|
        filter.decode(out_stream).should == in_stream
      end
    end

    it "should be symmetric" do
      examples.each do |in_stream, out_stream|
        filter.decode(filter.encode(in_stream)).should == in_stream

        filter.encode(filter.decode(out_stream)).should == out_stream
      end
    end
  end
end
