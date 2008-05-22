require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")   

class TextObserver                         
  
  attr_accessor :fonts, :size, :string
            
  FONTS = { :F1 => "Helvetica", 
            :F2 => "Courier",
            :F3 => "Times-Roman"  }
                                             
  def initialize     
    @fonts = []
  end
  
  def set_text_font_and_size(*params)     
    @fonts << { :name => FONTS[params[0]], :size => params[1] }
  end     
  
  def show_text(*params)
    @string = params[0]
  end
end

describe "when drawing text" do
   
   before(:each) { create_pdf } 
   
   it "should default to 12 point helvetica" do
      @pdf.text "Blah", :at => [100,100]              
      text = observer(TextObserver)
      text.fonts[0][:name].should == "Helvetica"
      text.fonts[0][:size].should == 12   
      text.string.should == "Blah"
   end   
   
   it "should allow setting font size" do
     @pdf.text "Blah", :at => [100,100], :size => 16
     text = observer(TextObserver)
     text.fonts[0][:size].should == 16
   end
   
   it "should allow registering of built-in fonts on the fly" do
     @pdf.font "Courier"
     @pdf.text "Blah", :at => [100,100]
     @pdf.font "Times-Roman"                    
     @pdf.text "Blaz", :at => [150,150]
     text = observer(TextObserver) 
            
     text.fonts[0][:name].should == "Courier"
     text.fonts[1][:name].should == "Times-Roman"
   end   
   
   it "should raise an exception when an unknown font is used" do
     lambda { @pdf.font "Pao bu" }.should raise_error(Prawn::Errors::UnknownFont)
   end

end