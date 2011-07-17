# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "#character_spacing" do
  it "should draw the character spacing to the document" do
    create_pdf
    @pdf.character_spacing(10.555555) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.character_spacing.first.should == 10.556
  end
  it "should not draw the character spacing to the document" +
    " when the new character spacing matches the old" do
    create_pdf
    @pdf.character_spacing(0) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.character_spacing.should.be.empty
  end
  it "should restore character spacing to 0" do
    create_pdf
    @pdf.character_spacing(10.555555) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.character_spacing.last.should == 0
  end
  it "should function as an accessor when no parameter given" do
    create_pdf
    @pdf.character_spacing(10.555555) do
      @pdf.text("hello world")
      @pdf.character_spacing.should == 10.555555
    end
    @pdf.character_spacing.should == 0
  end

  # ensure that we properly internationalize by using the number of characters
  # in a string, not the number of bytes, to insert character spaces
  #
  it "should calculate character spacing widths by characters, not bytes" do
    create_pdf
    @pdf.font("#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf")

    str = "こんにちは世界"
    @pdf.character_spacing(0) do
      @raw_width = @pdf.width_of(str)
    end

    @pdf.character_spacing(10) do
      # the new width should include seven 10-pt character spaces.
      @pdf.width_of(str).should.be.close(@raw_width + (10 * 7), 0.001)
    end
  end
end

describe "#word_spacing" do
  it "should draw the word spacing to the document" do
    create_pdf
    @pdf.word_spacing(10.555555) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.word_spacing.first.should == 10.556
  end
  it "should draw the word spacing to the document" +
    " when the new word spacing matches the old" do
    create_pdf
    @pdf.word_spacing(0) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.word_spacing.should.be.empty
  end
  it "should restore word spacing to 0" do
    create_pdf
    @pdf.word_spacing(10.555555) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.word_spacing.last.should == 0
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
