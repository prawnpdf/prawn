# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "A Reference object" do
  it "should produce a PDF reference on #to_s call" do
    ref = PDF::Core::Reference(1,true)
    ref.to_s.should == "1 0 R"
  end

  it "should allow changing generation number" do
    ref = PDF::Core::Reference(1,true)
    ref.gen = 1
    ref.to_s.should == "1 1 R"
  end

  it "should generate a valid PDF object for the referenced data" do
    ref = PDF::Core::Reference(2,[1,"foo"])
    ref.object.should == "2 0 obj\n#{PDF::Core::PdfObject([1,"foo"])}\nendobj\n"
  end

  it "should include stream fileds in dictionary when serializing" do
     ref = PDF::Core::Reference(1, {})
     ref.stream << 'Hello'
     ref.object.should == "1 0 obj\n<< /Length 5\n>>\nstream\nHello\nendstream\nendobj\n"
  end

  it "should append data to stream when #<< is used" do
     ref = PDF::Core::Reference(1, {})
     ref << "BT\n/F1 12 Tf\n72 712 Td\n( A stream ) Tj\nET"
     ref.object.should == "1 0 obj\n<< /Length 41\n>>\nstream"+
                           "\nBT\n/F1 12 Tf\n72 712 Td\n( A stream ) Tj\nET" +
                           "\nendstream\nendobj\n"
  end

  it "should copy the data and stream from another ref on #replace" do
    from = PDF::Core::Reference(3, {:foo => 'bar'})
    from << "has a stream too"

    to = PDF::Core::Reference(4, {:foo => 'baz'})
    to.replace from

    # should preserve identifier but copy data and stream
    to.identifier.should == 4
    to.data.should == from.data
    to.stream.should == from.stream
  end

  it "should copy a compressed stream from a compressed ref on #replace" do
    from = PDF::Core::Reference(5, {:foo => 'bar'})
    from << "has a stream too " * 20
    from.stream.compress!

    to = PDF::Core::Reference(6, {:foo => 'baz'})
    to.replace from

    to.identifier.should == 6
    to.data.should == from.data
    to.stream.should == from.stream
    to.stream.compressed?.should == true
  end

  describe "generated via Prawn::Document" do
    it "should return a proper reference on ref!" do
      pdf = Prawn::Document.new
      pdf.ref!({}).is_a?(PDF::Core::Reference).should == true
    end

    it "should return an identifier on ref" do
      pdf = Prawn::Document.new
      r = pdf.ref({})
      r.is_a?(Integer).should == true
    end

    it "should have :Length of stream if it has one when compression disabled" do
      pdf = Prawn::Document.new :compress => false
      ref = pdf.ref!({})
      ref << 'Hello'
      ref.stream.data[:Length].should == 5
    end
  end
end
