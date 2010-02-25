# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "#draw_text" do
  before(:each) { create_pdf }

  it "should raise ArgumentError if :at option omitted" do
    lambda { @pdf.draw_text("hai", { }) }.should.raise(ArgumentError)
  end

  it "should raise ArgumentError if :align option included" do
    lambda { @pdf.draw_text("hai", :at => [0, 0], :align => :center) }.should.raise(ArgumentError)
  end

  it "should default to 12 point helvetica" do
    @pdf.draw_text("Blah", :at => [100,100])
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:name].should == :Helvetica
    text.font_settings[0][:size].should == 12
    text.strings.first.should == "Blah"
  end

  it "should allow setting font size" do
    @pdf.draw_text("Blah", :at => [100,100], :size => 16)
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:size].should == 16
  end

  it "should allow setting a default font size" do
    @pdf.font_size = 16
    @pdf.draw_text("Blah", :at => [0, 0])
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:size].should == 16
  end

  it "should allow overriding default font for a single instance" do
    @pdf.font_size = 16

    @pdf.draw_text("Blah", :size => 11, :at => [0, 0])
    @pdf.draw_text("Blaz", :at => [0, 0])
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:size].should == 11
    text.font_settings[1][:size].should == 16
  end

  it "should allow setting a font size transaction with a block" do
    @pdf.font_size 16 do
      @pdf.draw_text('Blah', :at => [0, 0])
    end

    @pdf.draw_text('blah', :at => [0, 0])

    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:size].should == 16
    text.font_settings[1][:size].should == 12
  end

  it "should allow manual setting the font size " +
    "when in a font size block" do
    @pdf.font_size(16) do
      @pdf.draw_text('Foo', :at => [0, 0])
      @pdf.draw_text('Blah', :size => 11, :at => [0, 0])
      @pdf.draw_text('Blaz', :at => [0, 0])
    end
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:size].should == 16
    text.font_settings[1][:size].should == 11
    text.font_settings[2][:size].should == 16
  end

  it "should allow registering of built-in font_settings on the fly" do
    @pdf.font "Times-Roman"
    @pdf.draw_text("Blah", :at => [100,100], :at => [0, 0])
    @pdf.font "Courier"
    @pdf.draw_text("Blaz", :at => [150,150], :at => [0, 0])
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:name].should == :"Times-Roman"
    text.font_settings[1][:name].should == :Courier
  end

  it "should raise an exception when an unknown font is used" do
    lambda { @pdf.font "Pao bu" }.should.raise(Prawn::Errors::UnknownFont)
  end

  it "should correctly render a utf-8 string when using a built-in font" do
    str = "©" # copyright symbol
    @pdf.draw_text(str, :at => [0, 0])

    # grab the text from the rendered PDF and ensure it matches
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.first.should == str
  end

  if "spec".respond_to?(:encode!)
    # Handle non utf-8 string encodings in a sane way on M17N aware VMs
    it "should raise an exception when a utf-8 incompatible string is rendered" do
      str = "Blah \xDD"
      str.force_encoding("ASCII-8BIT")
      lambda { @pdf.draw_text(str, :at => [0, 0]) }.should.raise(ArgumentError)
    end
    it "should not raise an exception when a shift-jis string is rendered" do
      datafile = "#{Prawn::BASEDIR}/data/shift_jis_text.txt"
      sjis_str = File.open(datafile, "r:shift_jis") { |f| f.gets }
      @pdf.font("#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf")
      lambda { @pdf.draw_text(sjis_str, :at => [0, 0]) }.should.not.raise(ArgumentError)
    end
  else
    # Handle non utf-8 string encodings in a sane way on non-M17N aware VMs
    it "should raise an exception when a corrupt utf-8 string is rendered" do
      str = "Blah \xDD"
      lambda { @pdf.draw_text(str, :at => [0, 0]) }.should.raise(ArgumentError)
    end
    it "should raise an exception when a shift-jis string is rendered" do
      sjis_str = File.read("#{Prawn::BASEDIR}/data/shift_jis_text.txt")
      lambda { @pdf.draw_text(sjis_str, :at => [0, 0]) }.should.raise(ArgumentError)
    end
  end
end
