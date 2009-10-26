# encoding: utf-8
require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper") 

describe "When beginning each new page" do

  it "should execute codeblock given to Document#header" do
    call_count = 0    
   
    pdf = Prawn::Document.new      
    pdf.header(pdf.margin_box.top_left) do 
      call_count += 1   
    end
    
    pdf.start_new_page 
    pdf.start_new_page 
    pdf.render
    
    call_count.should == 3
  end

end

describe "When ending each page" do

  it "should execute codeblock given to Document#footer" do
   
    call_count = 0    
   
    pdf = Prawn::Document.new      
    pdf.footer([pdf.margin_box.left, pdf.margin_box.bottom + 50]) do 
      call_count += 1   
    end
    
    pdf.start_new_page 
    pdf.start_new_page 
    pdf.render
    
    call_count.should == 3
  end

end
