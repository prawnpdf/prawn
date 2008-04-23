require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "A Reference object" do
  it "should produce a PDF reference on #to_s call" do
    ref = Prawn::Reference(true)
    ref.to_s.should == "#{ref.object_id} 0 R"
  end                                        
  
  it "should allow changing generation number" do
    ref = Prawn::Reference(true)
    ref.gen = 1
    ref.to_s.should == "#{ref.object_id} 1 R"
  end
  
  it "should generate a valid PDF object for the referenced data" do
    ref = Prawn::Reference([1,"foo"]) 
    ref.object.should == "#{ref.object_id} 0 obj\n[1 (foo)]\nendobj\n" 
  end             
  
  it "should automatically open a stream when #<< is used" do
     ref = Prawn::Reference(:Length => 41)
     ref << "BT\n/F1 12 Tf\n72 712 Td\n( A stream ) Tj\nET"   
     ref.object.should == "#{ref.object_id} 0 obj\n<< /Length 41\n>>\nstream"+
                           "\nBT\n/F1 12 Tf\n72 712 Td\n( A stream ) Tj\nET" +
                           "\nendstream\nendobj\n"
  end
end