# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "A Reference object" do
  it "should produce a PDF reference on #to_s call" do
    ref = Prawn::Reference(1,true)
    ref.to_s.should == "1 0 R"
  end                                        
  
  it "should allow changing generation number" do
    ref = Prawn::Reference(1,true)
    ref.gen = 1
    ref.to_s.should == "1 1 R"
  end
  
  it "should generate a valid PDF object for the referenced data" do
    ref = Prawn::Reference(2,[1,"foo"]) 
    ref.object.should == "2 0 obj\n#{Prawn::PdfObject([1,"foo"])}\nendobj\n" 
  end             
  
  it "should automatically open a stream when #<< is used" do
     ref = Prawn::Reference(1, :Length => 41)
     ref << "BT\n/F1 12 Tf\n72 712 Td\n( A stream ) Tj\nET"   
     ref.object.should == "1 0 obj\n<< /Length 41\n>>\nstream"+
                           "\nBT\n/F1 12 Tf\n72 712 Td\n( A stream ) Tj\nET" +
                           "\nendstream\nendobj\n"
  end

  it "should compress a stream upon request" do
    ref = Prawn::Reference(2,{})
    ref << "Hi There " * 20

    cref = Prawn::Reference(2,{})
    cref << "Hi There " * 20
    cref.compress_stream

    assert cref.stream.size < ref.stream.size, 
      "compressed stream expected to be smaller than source but wasn't"
    cref.data[:Filter].should == :FlateDecode
  end
end
