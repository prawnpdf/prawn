require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper") 

describe "Document with transparency" do
  it "the PDF version should be at least 1.4" do
    create_pdf
    @pdf.transparent(0.5)
    str = @pdf.render
    str[0,8].should == "%PDF-1.4"
  end
  
  it "a new extended graphics state should be created for "+
     "each unique transparency setting" do
    create_pdf
    @pdf.transparent(0.5, 0.2)
    @pdf.transparent(0.5, 0.75)
    extgstates = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates
    extgstates.length.should == 2
  end
  
  it "a new extended graphics state should not be created for "+
     "each duplicate transparency setting" do
    create_pdf
    @pdf.transparent(0.5, 0.75)
    @pdf.transparent(0.5, 0.75)
    extgstates = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates
    extgstates.length.should == 1
  end

  it "setting the transparency with only one parameter sets the transparency"+
     " for both the fill and the stroke" do
    create_pdf
    @pdf.transparent(0.5)
    extgstate = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates[0]
    extgstate[:opacity].should == 0.5
    extgstate[:stroke_opacity].should == 0.5
  end

  it "setting the transparency with a numerical parameter and "+
     "a :stroke should set the fill transparency to the numerical parameter "+
     "and the stroke transparency to the option" do
    create_pdf
    @pdf.transparent(0.5, 0.2)
    extgstate = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates[0]
    extgstate[:opacity].should == 0.5
    extgstate[:stroke_opacity].should == 0.2
  end

  it "should enforce the valid range of 0.0 to 1.0" do
    create_pdf
    @pdf.transparent(-0.5, -0.2)
    extgstate = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates[0]
    extgstate[:opacity].should == 0.0
    extgstate[:stroke_opacity].should == 0.0

    create_pdf
    @pdf.transparent(2.0, 3.0)
    extgstate = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates[0]
    extgstate[:opacity].should == 1.0
    extgstate[:stroke_opacity].should == 1.0
  end
  
  describe "with more than one page" do
    it "the extended graphic state resource should be added to both pages" do
      create_pdf
      @pdf.transparent(0.5, 0.2)
      @pdf.start_new_page
      @pdf.transparent(0.5, 0.2)
      extgstates = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates
      extgstate = extgstates[0]
      extgstates.length.should == 2
      extgstate[:opacity].should == 0.5
      extgstate[:stroke_opacity].should == 0.2
    end
  end
end
