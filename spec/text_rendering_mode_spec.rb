# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "#text_rendering_mode" do
  it "should draw the text rendering mode to the document" do
    create_pdf
    @pdf.text_rendering_mode(:stroke) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.text_rendering_mode.first).to eq(1)
  end
  it "should not draw the text rendering mode to the document" \
    " when the new mode matches the old" do
    create_pdf
    @pdf.text_rendering_mode(:fill) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.text_rendering_mode).to be_empty
  end
  it "should restore character spacing to 0" do
    create_pdf
    @pdf.text_rendering_mode(:stroke) do
      @pdf.text("hello world")
    end
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.text_rendering_mode).to eq([1, 0])
  end
  it "should function as an accessor when no parameter given" do
    create_pdf
    @pdf.text_rendering_mode(:fill_stroke) do
      @pdf.text("hello world")
      expect(@pdf.text_rendering_mode).to eq(:fill_stroke)
    end
    expect(@pdf.text_rendering_mode).to eq(:fill)
  end
  it "should raise_error an exception when passed an invalid mode" do
    create_pdf
    expect { @pdf.text_rendering_mode(-1) }.to raise_error(ArgumentError)
    expect { @pdf.text_rendering_mode(8) }.to raise_error(ArgumentError)
    expect { @pdf.text_rendering_mode(:flil) }.to raise_error(ArgumentError)
  end
end
