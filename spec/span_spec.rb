# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "drawing span" do
  before do
    Prawn.debug = false
    create_pdf
  end

  after do
    Prawn.debug = true
  end

  it "should only accept :position as option in debug mode" do
    Prawn.debug = true
    expect { @pdf.span(350, :x => 3) {} }.to raise_error(Prawn::Errors::UnknownOption)
  end

  it "should have raise an error if :position is invalid" do
    expect { @pdf.span(350, :position => :x) {} }.to raise_error(ArgumentError)
  end

  it "should restore the margin box when bounding box exits" do
    margin_box = @pdf.bounds

    @pdf.span(350, :position => :center) do
      @pdf.text "Here's some centered text in a 350 point column. " * 100
    end

    expect(@pdf.bounds).to eq(margin_box)
  end

  it "should do create a margin box" do
    y = @pdf.y
    margin_box = @pdf.span(350, :position => :center) do
      @pdf.text "Here's some centered text in a 350 point column. " * 100
    end

    expect(margin_box.top).to eq(792.0)
    expect(margin_box.bottom).to eq(0)
  end
end
