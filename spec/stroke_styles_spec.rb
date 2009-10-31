# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "When stroking with default settings" do
  before(:each) { create_pdf }

  it "dashed? should be false" do
    @pdf.should.not.be.dashed
  end
end

describe "Dashes" do
  before(:each) { create_pdf }
  
   it "should be able to use assignment operator" do
     @pdf.dash = 2
     @pdf.should.be.dashed
  end

  describe "setting a dash" do
    it "dashed? should be true" do
      @pdf.dash(2)
      @pdf.should.be.dashed
    end
    it "rendered PDF should include a stroked dash" do
      @pdf.dash(2)
      dashes = PDF::Inspector::Graphics::Dash.analyze(@pdf.render)
      dashes.stroke_dash.should == [[2, 2], 0]
    end
  end

  describe "setting a dash by passing a single argument" do
    it "space between dashes should be the same length as the dash in the rendered PDF" do
      @pdf.dash(2)
      dashes = PDF::Inspector::Graphics::Dash.analyze(@pdf.render)
      dashes.stroke_dash.should == [[2, 2], 0]
    end
  end

  describe "with a space option that differs from the first argument" do
    it "space between dashes in the rendered PDF should be different length than the length of the dash" do
      @pdf.dash(2, :space => 3)
      dashes = PDF::Inspector::Graphics::Dash.analyze(@pdf.render)
      dashes.stroke_dash.should == [[2, 3], 0]
    end
  end

  describe "with a non-zero phase option" do
    it "rendered PDF should include a non-zero phase" do
      @pdf.dash(2, :phase => 1)
      dashes = PDF::Inspector::Graphics::Dash.analyze(@pdf.render)
      dashes.stroke_dash.should == [[2, 2], 1]
    end
  end

  describe "clearing stroke dash" do
    it "should restore solid line" do
      @pdf.dash(2)
      @pdf.undash
      dashes = PDF::Inspector::Graphics::Dash.analyze(@pdf.render)
      dashes.stroke_dash.should == [[], 0]
    end
  end

  it "should reset the stroke dash on each new page if it has been defined" do
    @pdf.start_new_page
    @pdf.dash(2)
    dashes = PDF::Inspector::Graphics::Dash.analyze(@pdf.render)
    dashes.stroke_dash_count.should == 1

    @pdf.start_new_page
    dashes = PDF::Inspector::Graphics::Dash.analyze(@pdf.render)
    dashes.stroke_dash_count.should == 2
    dashes.stroke_dash.should == [[], 0]
    @pdf.dash.should == { :dash => nil, :space => nil, :phase => 0 }
  end

end
