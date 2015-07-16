# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

module TransparencyHelper
  def make_transparent(opacity, stroke_opacity = opacity)
    @pdf.transparent(opacity, stroke_opacity) do
      yield if block_given?
    end
  end
end

describe "Document with transparency" do
  include TransparencyHelper

  it "the PDF version should be at least 1.4" do
    create_pdf
    make_transparent(0.5)
    str = @pdf.render
    expect(str[0, 8]).to eq("%PDF-1.4")
  end

  it "a new extended graphics state should be created for " \
     "each unique transparency setting" do
    create_pdf
    make_transparent(0.5, 0.2) do
      make_transparent(0.5, 0.75)
    end
    extgstates = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates
    expect(extgstates.length).to eq(2)
  end

  it "a new extended graphics state should not be created for " \
     "each duplicate transparency setting" do
    create_pdf
    make_transparent(0.5, 0.75) do
      make_transparent(0.5, 0.75)
    end
    extgstates = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates
    expect(extgstates.length).to eq(1)
  end

  it "setting the transparency with only one parameter sets the transparency" \
     " for both the fill and the stroke" do
    create_pdf
    make_transparent(0.5)
    extgstate = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates[0]
    expect(extgstate[:opacity]).to eq(0.5)
    expect(extgstate[:stroke_opacity]).to eq(0.5)
  end

  it "setting the transparency with a numerical parameter and " \
     "a :stroke should set the fill transparency to the numerical parameter " \
     "and the stroke transparency to the option" do
    create_pdf
    make_transparent(0.5, 0.2)
    extgstate = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates[0]
    expect(extgstate[:opacity]).to eq(0.5)
    expect(extgstate[:stroke_opacity]).to eq(0.2)
  end

  it "should enforce the valid range of 0.0 to 1.0" do
    create_pdf
    make_transparent(-0.5, -0.2)
    extgstate = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates[0]
    expect(extgstate[:opacity]).to eq(0.0)
    expect(extgstate[:stroke_opacity]).to eq(0.0)

    create_pdf
    make_transparent(2.0, 3.0)
    extgstate = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates[0]
    expect(extgstate[:opacity]).to eq(1.0)
    expect(extgstate[:stroke_opacity]).to eq(1.0)
  end

  describe "with more than one page" do
    include TransparencyHelper

    it "the extended graphic state resource should be added to both pages" do
      create_pdf
      make_transparent(0.5, 0.2)
      @pdf.start_new_page
      make_transparent(0.5, 0.2)
      extgstates = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates
      extgstate = extgstates[0]
      expect(extgstates.length).to eq(2)
      expect(extgstate[:opacity]).to eq(0.5)
      expect(extgstate[:stroke_opacity]).to eq(0.2)
    end
  end
end
