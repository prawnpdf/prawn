# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")   

class TextObserver                         
  
  attr_accessor :font_settings, :size, :string
            
  def initialize     
    @font_settings = []
    @fonts = {}
  end
  
  def resource_font(*params)
    @fonts[params[0]] = params[1].basefont
  end

  def set_text_font_and_size(*params)     
    @font_settings << { :name => @fonts[params[0]], :size => params[1] }
  end     
  
  def show_text(*params)
    @string = params[0]
  end
end

class FontObserver

  attr_accessor :page_fonts

  def initialize
    @page_fonts = []
  end

  def resource_font(*params)
    @page_fonts.last << params[1].basefont
  end

  def begin_page(*params)
    @page_fonts << []
  end
end

describe "Font Metrics" do

  it "should default to Helvetica if no font is specified" do
    @pdf = Prawn::Document.new
    @pdf.font_metrics.should == Prawn::Font::Metrics["Helvetica"]
  end

  it "should use the currently set font for font_metrics" do
    @pdf = Prawn::Document.new
    @pdf.font "Courier"
    @pdf.font_metrics.should == Prawn::Font::Metrics["Courier"]
   
    comicsans = "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf"
    @pdf.font(comicsans)
    @pdf.font_metrics.should == Prawn::Font::Metrics[comicsans]
  end

end

describe "when drawing text" do
   
   before(:each) { create_pdf } 

   it "should advance down the document based on font_height" do
     position = @pdf.y
     @pdf.text "Foo"

     @pdf.y.should be_close(position - @pdf.font_metrics.font_height(12),
                            0.0001)

     position = @pdf.y
     @pdf.text "Foo\nBar\nBaz"
     @pdf.y.should be_close(position - 3*@pdf.font_metrics.font_height(12),
                            0.0001)
   end
   
   it "should default to 12 point helvetica" do
      @pdf.text "Blah", :at => [100,100]              
      text = observer(TextObserver)
      text.font_settings[0][:name].should == :Helvetica
      text.font_settings[0][:size].should == 12   
      text.string.should == "Blah"
   end   
   
   it "should allow setting font size" do
     @pdf.text "Blah", :at => [100,100], :size => 16
     text = observer(TextObserver)
     text.font_settings[0][:size].should == 16
   end
   
   it "should allow setting a default font size" do
     @pdf.font_size! 16
     @pdf.text "Blah"
     text = observer(TextObserver)
     text.font_settings[0][:size].should == 16
   end
   
   it "should allow overriding default font for a single instance" do
     @pdf.font_size! 16

     @pdf.text "Blah", :size => 11
     @pdf.text "Blaz"
     text = observer(TextObserver)
     text.font_settings[0][:size].should == 11
     text.font_settings[1][:size].should == 16
   end
   
   
   it "should allow setting a font size transaction with a block" do
     @pdf.font_size 16 do
       @pdf.text 'Blah'
     end

     @pdf.text 'blah'

     text = observer(TextObserver)
     text.font_settings[0][:size].should == 16
     text.font_settings[1][:size].should == 12
   end
   
   it "should allow manual setting the font size " +
       "when in a font size block" do
     @pdf.font_size 16 do
        @pdf.text 'Foo'
        @pdf.text 'Blah', :size => 11
        @pdf.text 'Blaz'
      end
      text = observer(TextObserver)
      text.font_settings[0][:size].should == 16
      text.font_settings[1][:size].should == 11
      text.font_settings[2][:size].should == 16
   end
      
   it "should allow registering of built-in font_settings on the fly" do
     @pdf.font "Courier"
     @pdf.text "Blah", :at => [100,100]
     @pdf.font "Times-Roman"                    
     @pdf.text "Blaz", :at => [150,150]
     text = observer(TextObserver) 
            
     text.font_settings[0][:name].should == :Courier
     text.font_settings[1][:name].should == :"Times-Roman"
   end   

   it "should utilise the same default font across multiple pages" do
     @pdf.text "Blah", :at => [100,100]
     @pdf.start_new_page
     @pdf.text "Blaz", :at => [150,150]
     text = observer(FontObserver)

     text.page_fonts.size.should eql(2)
     text.page_fonts[0][0].should eql(:Helvetica)
     text.page_fonts[1][0].should eql(:Helvetica)
   end
   
   it "should raise an exception when an unknown font is used" do
     lambda { @pdf.font "Pao bu" }.should raise_error(Prawn::Errors::UnknownFont)
   end

   if "spec".respond_to?(:encode!)
     # Handle non utf-8 string encodings in a sane way on M17N aware VMs
     it "should raise an exception when a utf-8 incompatible string is rendered" do
       str = "Blah \xDD"
       str.force_encoding("ASCII-8BIT")
       lambda { @pdf.text str }.should raise_error(Prawn::Errors::IncompatibleStringEncoding)
     end
     it "should not raise an exception when a shift-jis string is rendered" do
       sjis_str = File.read("#{Prawn::BASEDIR}/data/shift_jis_text.txt")
       lambda { @pdf.text sjis_str }.should_not raise_error(Prawn::Errors::IncompatibleStringEncoding)
     end
   else
     # Handle non utf-8 string encodings in a sane way on non-M17N aware VMs
     it "should raise an exception when a corrupt utf-8 string is rendered" do
       str = "Blah \xDD"
       lambda { @pdf.text str }.should raise_error(Prawn::Errors::IncompatibleStringEncoding)
     end
     it "should raise an exception when a shift-jis string is rendered" do
       sjis_str = File.read("#{Prawn::BASEDIR}/data/shift_jis_text.txt")
       lambda { @pdf.text sjis_str }.should raise_error(Prawn::Errors::IncompatibleStringEncoding)
     end
   end

end
