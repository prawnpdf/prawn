# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Stream object" do
  it "should compress a stream upon request" do
    stream = Prawn::Core::Stream.new
    stream << "Hi There " * 20

    cstream = Prawn::Core::Stream.new
    cstream << "Hi There " * 20
    cstream.compress!

    cstream.filtered_stream.length.should be < stream.length,
      "compressed stream expected to be smaller than source but wasn't"
    cstream.data[:Filter].should == [:FlateDecode]
  end

  it "should expose sompression state" do
    stream = Prawn::Core::Stream.new
    stream << "Hello"
    stream.compress!

    stream.should be_compressed
  end

  it "should detect from filters if stream is compressed" do
    stream = Prawn::Core::Stream.new
    stream << "Hello"
    stream.filters << :FlateDecode

    stream.should be_compressed
  end

  it "should have Length if in data" do
    stream = Prawn::Core::Stream.new
    stream << "hello"

    stream.data[:Length].should == 5
  end

  it "should update Length when updated" do
    stream = Prawn::Core::Stream.new
    stream << "hello"
    stream.data[:Length].should == 5

    stream << " world"
    stream.data[:Length].should == 11
  end
end
