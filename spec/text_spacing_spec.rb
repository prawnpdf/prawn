# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "#character_spacing" do
  it "should draw the character spacing to the document" do
    create_pdf
    @pdf.character_spacing(10.555555) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.character_spacing.first).to eq(10.5556)
  end
  it "should not draw the character spacing to the document" \
    " when the new character spacing matches the old" do
    create_pdf
    @pdf.character_spacing(0) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.character_spacing).to be_empty
  end
  it "should restore character spacing to 0" do
    create_pdf
    @pdf.character_spacing(10.555555) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.character_spacing.last).to eq(0)
  end
  it "should function as an accessor when no parameter given" do
    create_pdf
    @pdf.character_spacing(10.555555) do
      @pdf.text("hello world")
      expect(@pdf.character_spacing).to eq(10.555555)
    end
    expect(@pdf.character_spacing).to eq(0)
  end

  # ensure that we properly internationalize by using the number of characters
  # in a string, not the number of bytes, to insert character spaces
  #
  it "should calculate character spacing widths by characters, not bytes" do
    create_pdf
    @pdf.font("#{Prawn::DATADIR}/fonts/gkai00mp.ttf")

    str = "こんにちは世界"
    @pdf.character_spacing(0) do
      @raw_width = @pdf.width_of(str)
    end

    @pdf.character_spacing(10) do
      # the new width should include seven 10-pt character spaces.
      expect(@pdf.width_of(str)).to be_within(0.001).of(@raw_width + (10 * 7))
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
    expect(contents.word_spacing.first).to eq(10.5556)
  end
  it "should draw the word spacing to the document" \
    " when the new word spacing matches the old" do
    create_pdf
    @pdf.word_spacing(0) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.word_spacing).to be_empty
  end
  it "should restore word spacing to 0" do
    create_pdf
    @pdf.word_spacing(10.555555) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.word_spacing.last).to eq(0)
  end
  it "should function as an accessor when no parameter given" do
    create_pdf
    @pdf.word_spacing(10.555555) do
      @pdf.text("hello world")
      expect(@pdf.word_spacing).to eq(10.555555)
    end
    expect(@pdf.word_spacing).to eq(0)
  end
end
