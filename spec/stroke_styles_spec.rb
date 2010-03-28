# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "When stroking with default settings" do
  before(:each) { create_pdf }
  it "cap_style should be :butt" do
    @pdf.cap_style.should == :butt
  end
  
  it "join_style should be :miter" do
    @pdf.join_style.should == :miter
  end

  it "dashed? should be false" do
    @pdf.should.not.be.dashed
  end
end

describe "Cap styles" do
  before(:each) { create_pdf }
  
  it "should be able to use assignment operator" do
    @pdf.cap_style = :round
    @pdf.cap_style.should == :round
  end
  
  describe "#cap_style(:butt)" do
    it "rendered PDF should include butt style cap" do
      @pdf.cap_style(:butt)
      cap_style = PDF::Inspector::Graphics::CapStyle.analyze(@pdf.render).cap_style
      cap_style.should == 0
    end
  end

  describe "#cap_style(:round)" do
    it "rendered PDF should include round style cap" do
      @pdf.cap_style(:round)
      cap_style = PDF::Inspector::Graphics::CapStyle.analyze(@pdf.render).cap_style
      cap_style.should == 1
    end
  end

  describe "#cap_style(:projecting_square)" do
    it "rendered PDF should include projecting_square style cap" do
      @pdf.cap_style(:projecting_square)
      cap_style = PDF::Inspector::Graphics::CapStyle.analyze(@pdf.render).cap_style
      cap_style.should == 2
    end
  end

  it "should carry the current cap style settings over to new pages" do
    @pdf.cap_style(:round)
    @pdf.start_new_page
    cap_styles = PDF::Inspector::Graphics::CapStyle.analyze(@pdf.render)
    cap_styles.cap_style_count.should == 2
    cap_styles.cap_style.should == 1
  end
end

describe "Join styles" do
  before(:each) { create_pdf }
  
  it "should be able to use assignment operator" do
    @pdf.join_style = :round
    @pdf.join_style.should == :round
  end
  
  describe "#join_style(:miter)" do
    it "rendered PDF should include miter style join" do
      @pdf.join_style(:miter)
      join_style = PDF::Inspector::Graphics::JoinStyle.analyze(@pdf.render).join_style
      join_style.should == 0
    end
  end

  describe "#join_style(:round)" do
    it "rendered PDF should include round style join" do
      @pdf.join_style(:round)
      join_style = PDF::Inspector::Graphics::JoinStyle.analyze(@pdf.render).join_style
      join_style.should == 1
    end
  end

  describe "#join_style(:bevel)" do
    it "rendered PDF should include bevel style join" do
      @pdf.join_style(:bevel)
      join_style = PDF::Inspector::Graphics::JoinStyle.analyze(@pdf.render).join_style
      join_style.should == 2
    end
  end

  it "should carry the current join style settings over to new pages" do
    @pdf.join_style(:round)
    @pdf.start_new_page
    join_styles = PDF::Inspector::Graphics::JoinStyle.analyze(@pdf.render)
    join_styles.join_style_count.should == 2
    join_styles.join_style.should == 1
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
 
  it "should carry the current dash settings over to new pages" do
    @pdf.dash(2)
    @pdf.start_new_page
    dashes = PDF::Inspector::Graphics::Dash.analyze(@pdf.render)
    dashes.stroke_dash_count.should == 2
    dashes.stroke_dash.should == [[2, 2], 0]
  end

end
