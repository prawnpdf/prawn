require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper") 

describe "Document with a stamp" do
  it "should raise NameTaken error when attempt to create stamp with same name as an existing stamp" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    lambda {
      @pdf.create_stamp("MyStamp")
    }.should raise_error(Prawn::Errors::NameTaken)
  end
  
  it "should raise InvalidName error when attempt to create stamp with a blank name" do
    create_pdf
    lambda {
      @pdf.create_stamp("")
    }.should raise_error(Prawn::Errors::InvalidName)
  end
  
  it "should raise InvalidName error when attempt to create stamp with only non-alphanumeric characters" do
    create_pdf
    lambda {
      @pdf.create_stamp("_*!@")
    }.should raise_error(Prawn::Errors::InvalidName)
  end
  
  it "should raise InvalidName error when attempt to create stamp with number as first character" do
    create_pdf
    lambda {
      @pdf.create_stamp("7MyStamp")
    }.should raise_error(Prawn::Errors::InvalidName)
  end
  
  it "a new XObject should be defined for each stamp created" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    @pdf.create_stamp("AnotherStamp")
    @pdf.stamp("MyStamp")
    @pdf.stamp("AnotherStamp")
    
    xobjects = PDF::Inspector::XObject.analyze(@pdf.render).page_xobjects.last
    xobjects.length.should == 2
  end

  it "calling stamp with a name that does not match an existing stamp should raise UndefinedObjectName" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    lambda {
      @pdf.stamp("OtherStamp")
    }.should raise_error(Prawn::Errors::UndefinedObjectName)
  end

  it "stamp should be drawn into the document each time stamp is called" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    @pdf.stamp("MyStamp")
    @pdf.stamp("MyStamp")
    @pdf.stamp("MyStamp")
    PDF::Inspector::XObject.analyze(@pdf.render).xobjects_drawn_on_this_page.should == 3
  end

#   it "" do
#     create_pdf
#     @pdf.create_stamp("MyStamp")
#   end

#   it "" do
#     create_pdf
#     @pdf.create_stamp("MyStamp")
#   end

#   it "" do
#     create_pdf
#     @pdf.create_stamp("MyStamp")
#   end

#   it "" do
#     create_pdf
#     @pdf.create_stamp("MyStamp")
#   end

#   it "setting the transparency with a numerical parameter and a :stroke should set the fill transparency to the numerical parameter and the stroke transparency to the option" do
#     create_pdf
#     @pdf.transparent(0.5, 0.2)
#     extgstate = PDF::Inspector::XObject.analyze(@pdf.render).extgstates[0]
#     extgstate[:opacity].should == 0.5
#     extgstate[:stroke_opacity].should == 0.2
#   end
  
#   describe "with more than one page" do
#     it "the extended graphic state resource should be added to both pages" do
#       create_pdf
#       @pdf.transparent(0.5, 0.2)
#       @pdf.start_new_page
#       @pdf.transparent(0.5, 0.2)
#       extgstates = PDF::Inspector::XObject.analyze(@pdf.render).extgstates
#       extgstate = extgstates[0]
#       extgstates.length.should == 2
#       extgstate[:opacity].should == 0.5
#       extgstate[:stroke_opacity].should == 0.2
#     end
#   end
end
