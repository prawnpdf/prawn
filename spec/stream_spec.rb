# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Stream object" do
  it "should compress a stream upon request" do
    stream = PDF::Core::Stream.new
    stream << "Hi There " * 20

    cstream = PDF::Core::Stream.new
    cstream << "Hi There " * 20
    cstream.compress!

    cstream.filtered_stream.length.should be < stream.length,
      "compressed stream expected to be smaller than source but wasn't"
    cstream.data[:Filter].should == [:FlateDecode]
  end

  it "should expose sompression state" do
    stream = PDF::Core::Stream.new
    stream << "Hello"
    stream.compress!

    stream.should be_compressed
  end

  it "should detect from filters if stream is compressed" do
    stream = PDF::Core::Stream.new
    stream << "Hello"
    stream.filters << :FlateDecode

    stream.should be_compressed
  end

  it "should have Length if in data" do
    stream = PDF::Core::Stream.new
    stream << "hello"

    stream.data[:Length].should == 5
  end

  it "should update Length when updated" do
    stream = PDF::Core::Stream.new
    stream << "hello"
    stream.data[:Length].should == 5

    stream << " world"
    stream.data[:Length].should == 11
  end

  it "should corecly handle decode params" do
    stream = PDF::Core::Stream.new
    stream << "Hello"
    stream.filters << { :FlateDecode => { :Predictor => 15 } }

    stream.data[:DecodeParms].should == [{ :Predictor => 15 }]
  end
end
