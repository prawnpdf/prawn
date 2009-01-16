# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")      

describe "when drawing text" do     
   
   before(:each) { create_pdf } 

   it "should advance down the document based on font_height" do
     position = @pdf.y
     @pdf.text "Foo"

     @pdf.y.should.be.close(position - @pdf.font.height, 0.0001)

     position = @pdf.y
     @pdf.text "Foo\nBar\nBaz"
     @pdf.y.should.be.close(position - 3*@pdf.font.height, 0.0001)
   end
   
   it "should advance down the document based on font ascender only if final_gap is given" do
     position = @pdf.y
     @pdf.text "Foo", :final_gap => false

     @pdf.y.should.be.close(position - @pdf.font.ascender, 0.0001)

     position = @pdf.y
     @pdf.text "Foo\nBar\nBaz", :final_gap => false
     @pdf.y.should.be.close(position - 2*@pdf.font.height - @pdf.font.ascender, 0.0001)
   end

   it "should default to 12 point helvetica" do
      @pdf.text "Blah", :at => [100,100]              
      text = PDF::Inspector::Text.analyze(@pdf.render)  
      text.font_settings[0][:name].should == :Helvetica
      text.font_settings[0][:size].should == 12   
      text.strings.first.should == "Blah"
   end   
   
   it "should allow setting font size" do
     @pdf.text "Blah", :at => [100,100], :size => 16
     text = PDF::Inspector::Text.analyze(@pdf.render)  
     text.font_settings[0][:size].should == 16
   end
   
   it "should allow setting a default font size" do
     @pdf.font_size = 16
     @pdf.text "Blah"
     text = PDF::Inspector::Text.analyze(@pdf.render)  
     text.font_settings[0][:size].should == 16
   end

   it "should allow setting font size in DSL style" do
     @pdf.font_size 20
     @pdf.font_size.should == 20
   end
   
   it "should allow overriding default font for a single instance" do
     @pdf.font_size = 16

     @pdf.text "Blah", :size => 11
     @pdf.text "Blaz"
     text = PDF::Inspector::Text.analyze(@pdf.render)  
     text.font_settings[0][:size].should == 11
     text.font_settings[1][:size].should == 16
   end
   
   it "should allow setting a font size transaction with a block" do
     @pdf.font_size 16 do
       @pdf.text 'Blah'
     end

     @pdf.text 'blah'

     text = PDF::Inspector::Text.analyze(@pdf.render)  
     text.font_settings[0][:size].should == 16
     text.font_settings[1][:size].should == 12
   end
   
   it "should allow manual setting the font size " +
       "when in a font size block" do
     @pdf.font_size(16) do
        @pdf.text 'Foo'
        @pdf.text 'Blah', :size => 11
        @pdf.text 'Blaz'
      end
      text = PDF::Inspector::Text.analyze(@pdf.render)  
      text.font_settings[0][:size].should == 16
      text.font_settings[1][:size].should == 11
      text.font_settings[2][:size].should == 16
   end
      
   it "should allow registering of built-in font_settings on the fly" do
     @pdf.font "Times-Roman"
     @pdf.text "Blah", :at => [100,100]
     @pdf.font "Courier"                    
     @pdf.text "Blaz", :at => [150,150]
     text = PDF::Inspector::Text.analyze(@pdf.render)                      
     text.font_settings[0][:name].should == :"Times-Roman"  
     text.font_settings[1][:name].should == :Courier
   end   

   it "should utilise the same default font across multiple pages" do
     @pdf.text "Blah", :at => [100,100]
     @pdf.start_new_page
     @pdf.text "Blaz", :at => [150,150]
     text = PDF::Inspector::Text.analyze(@pdf.render)  

     text.font_settings.size.should  == 2
     text.font_settings[0][:name].should == :Helvetica
     text.font_settings[1][:name].should == :Helvetica
   end
   
   it "should raise an exception when an unknown font is used" do
     lambda { @pdf.font "Pao bu" }.should.raise(Prawn::Errors::UnknownFont)
   end

   it "should correctly render a utf-8 string when using a built-in font" do
     str = "©" # copyright symbol
     @pdf.text str

     # grab the text from the rendered PDF and ensure it matches
     text = PDF::Inspector::Text.analyze(@pdf.render)
     text.strings.first.should == str
   end
                    
   if "spec".respond_to?(:encode!)
     # Handle non utf-8 string encodings in a sane way on M17N aware VMs
     it "should raise an exception when a utf-8 incompatible string is rendered" do
       str = "Blah \xDD"
       str.force_encoding("ASCII-8BIT")
       lambda { @pdf.text str }.should.raise(ArgumentError)
     end
     it "should not raise an exception when a shift-jis string is rendered" do 
       datafile = "#{Prawn::BASEDIR}/data/shift_jis_text.txt"  
       sjis_str = File.open(datafile, "r:shift_jis") { |f| f.gets } 
       @pdf.font("#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf")
       lambda { @pdf.text sjis_str }.should.not.raise(ArgumentError)
     end
   else
     # Handle non utf-8 string encodings in a sane way on non-M17N aware VMs
     it "should raise an exception when a corrupt utf-8 string is rendered" do
       str = "Blah \xDD"
       lambda { @pdf.text str }.should.raise(ArgumentError)
     end
     it "should raise an exception when a shift-jis string is rendered" do
       sjis_str = File.read("#{Prawn::BASEDIR}/data/shift_jis_text.txt")
       lambda { @pdf.text sjis_str }.should.raise(ArgumentError)
     end
   end 

  it "should wrap text" do
    @pdf = Prawn::Document.new
    @pdf.font "Courier"

    text = "Please wrap this text about HERE. More text that should be wrapped"
    expect = "Please wrap this text about\nHERE. More text that should be\nwrapped"

    @pdf.naive_wrap(text, 220, @pdf.font_size).should == expect
  end

  it "should respect end of line when wrapping text" do
    @pdf = Prawn::Document.new
    @pdf.font "Courier"
    text = "Please wrap only before\nTHIS word. Don't wrap this"
    @pdf.naive_wrap(text, 220, @pdf.font_size).should == text
  end

  it "should respect end of line when wrapping text and mode is set to 'character'" do
    @pdf = Prawn::Document.new
    @pdf.font "Courier"

    text = "You can wrap this text HERE"
    expect = "You can wrap this text HE\nRE"

    @pdf.naive_wrap(text, 180, @pdf.font_size, :mode => :character).should == expect
  end     
  
end
