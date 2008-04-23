require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

# See PDF Reference, Sixth Edition (1.7) pp51-60 for details 
describe "PDF Object Serialization" do     
              
  it "should convert Ruby's nil to PDF null" do
    Prawn::PdfObject(nil).should == "null"
  end
  
  it "should convert Ruby booleans to PDF booleans" do
    Prawn::PdfObject(true).should  == "true"
    Prawn::PdfObject(false).should == "false"
  end
                                          
  it "should convert a Ruby number to PDF number" do
    Prawn::PdfObject(1).should == "1"
    Prawn::PdfObject(1.214112421).should == "1.214112421" 
  end
  
  it "should convert a Ruby string to PDF string" do
    Prawn::PdfObject("I can has a string").should == "(I can has a string)"  
  end               
  
  it "should escape parens when converting from Ruby string to PDF" do
    Prawn::PdfObject("I (can) has a string").should == 
      '(I \(can\) has a string)'
  end                     
  
  it "should convert a Ruby symbol to PDF name" do
    Prawn::PdfObject(:my_symbol).should == "/my_symbol"
    Prawn::PdfObject(:"A;Name_With−Various***Characters?").should ==
     "/A;Name_With−Various***Characters?"
  end
 
  it "should not convert a whitespace containing Ruby symbol to a PDF name" do
    lambda { Prawn::PdfObject(:"My Symbol With Spaces") }.
      should raise_error(Prawn::ObjectConversionError)
  end    
  
  it "should convert a Ruby array to PDF Array" do
    Prawn::PdfObject([1,2,3]).should == "[1 2 3]"
    Prawn::PdfObject([[1,2],:foo,"Bar"]).should == "[[1 2] /foo (Bar)]"    
  end  
 
  it "should convert a Ruby hash to a PDF Dictionary" do
    dict = Prawn::PdfObject( :foo  => :bar, 
                             "baz"  => [1,2,3], 
                             :bang => {:a => "what", :b => [:you, :say] } )
                            
    dict[0..1].should == "<<"
    dict[-2..-1].should == ">>"   
    dict.should match(%r{/foo /bar\n})   
    dict.should match(%r{/baz \[1 2 3\]\n})    
    dict.should match(%r{/bang << /a \(what\)\n/b \[/you /say\]\n>>\n})
  end      
  
  it "should not allow keys other than strings or symbols for PDF dicts" do
    lambda { Prawn::PdfObject(:foo => :bar, :baz => :bang, 1 => 4) }.
      should raise_error(Prawn::ObjectConversionError) 
  end
end