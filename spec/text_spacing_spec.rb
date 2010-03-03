# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "#character_spacing" do
  it "should draw the character spacing to the document" do
    create_pdf
    @pdf.character_spacing(10.555555) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.character_spacing[0].should == 10.556
  end
  it "should restore character spacing to 0" do
    create_pdf
    @pdf.character_spacing(10.555555) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.character_spacing[1].should == 0
  end
  it "should function as an accessor when no parameter given" do
    create_pdf
    @pdf.character_spacing(10.555555) do
      @pdf.text("hello world")
      @pdf.character_spacing.should == 10.555555
    end
    @pdf.character_spacing.should == 0
  end
end

describe "#word_spacing" do
  it "should draw the word spacing to the document" do
    create_pdf
    @pdf.word_spacing(10.555555) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.word_spacing[0].should == 10.556
  end
  it "should restore word spacing to 0" do
    create_pdf
    @pdf.word_spacing(10.555555) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.word_spacing[1].should == 0
  end
  it "should function as an accessor when no parameter given" do
    create_pdf
    @pdf.word_spacing(10.555555) do
      @pdf.text("hello world")
      @pdf.word_spacing.should == 10.555555
    end
    @pdf.word_spacing.should == 0
  end
end
