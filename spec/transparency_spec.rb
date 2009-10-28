require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper") 

describe "Document with transparency" do
  it "the PDF version should be at least 1.4" do
    create_pdf
    @pdf.set_opacity(0.5)
    str = @pdf.render
    str[0,8].should == "%PDF-1.4"
  end
  
  it "a new extended graphics state should be created for each unique transparency setting" do
    create_pdf
    @pdf.set_opacity(0.5, :stroke => 0.2)
    @pdf.set_opacity(0.5, :stroke => 0.75)
    extgstates = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates
    extgstates.length.should == 2
  end
  
  it "a new extended graphics state should not be created for each duplicate transparency setting" do
    create_pdf
    @pdf.set_opacity(0.5, :stroke => 0.75)
    @pdf.set_opacity(0.5, :stroke => 0.75)
    extgstates = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates
    extgstates.length.should == 1
  end

  it "setting the transparency with only one parameter sets the transparency for both the fill and the stroke" do
    create_pdf
    @pdf.set_opacity(0.5)
    extgstate = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates[0]
    extgstate.opacity.should == 0.5
    extgstate.stroke_opacity.should == 0.5
  end

  it "setting the transparency with a numerical parameter and a :stroke should set the fill transparency to the numerical parameter and the stroke transparency to the option" do
    create_pdf
    @pdf.set_opacity(0.5, :stroke => 0.2)
    extgstate = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates[0]
    extgstate.opacity.should == 0.5
    extgstate.stroke_opacity.should == 0.2
  end

  it "the extended graphics state should reference the transparency library object id" do
    create_pdf
    @pdf.set_opacity(0.5, :stroke => 0.2)
    extgstate = PDF::Inspector::ExtGState.analyze(@pdf.render).extgstates[0]
    transparency_library = PDF::Inspector::TransparencyLibrary.analyze(@pdf.render).transparency_libraries[0]
    extgstate.child_object_id.should == transparency_library.object_id
  end
end
