require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")   

class TextObserver                         
  
  attr_accessor :font, :size, :string
            
  # Hacky, should maybe rethink
  FONTS = { :F1 => "Helvetica" }
  
  def set_text_font_and_size(*params) 
    @font = FONTS[params[0]]
    @size = params[1] 
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
      text.font.should == "Helvetica"
      text.size.should == 12   
      text.string.should == "Blah"
   end   
   
   it "should allow setting font size" do
     @pdf.text "Blah", :at => [100,100], :size => 16
     text = observer(TextObserver)
     text.size.should == 16
   end

end