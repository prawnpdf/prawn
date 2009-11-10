require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper") 

describe "Document with a stamp" do
  it "should raise NameTaken error when attempt to create stamp "+
     "with same name as an existing stamp" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    lambda {
      @pdf.create_stamp("MyStamp")
    }.should.raise(Prawn::Errors::NameTaken)
  end
  
  it "should raise InvalidName error when attempt to create "+
     "stamp with a blank name" do
    create_pdf
    lambda {
      @pdf.create_stamp("")
    }.should.raise(Prawn::Errors::InvalidName)
  end
  
  it "a new XObject should be defined for each stamp created" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    @pdf.create_stamp("AnotherStamp")
    @pdf.stamp("MyStamp")
    @pdf.stamp("AnotherStamp")
    
    inspector = PDF::Inspector::XObject.analyze(@pdf.render)
    xobjects = inspector.page_xobjects.last
    xobjects.length.should == 2
  end

  it "calling stamp with a name that does not match an existing stamp "+
     "should raise UndefinedObjectName" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    lambda {
      @pdf.stamp("OtherStamp")
    }.should.raise(Prawn::Errors::UndefinedObjectName)
  end

  it "stamp should be drawn into the document each time stamp is called" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    @pdf.stamp("MyStamp")
    @pdf.stamp("MyStamp")
    @pdf.stamp("MyStamp")
    # I had modified PDF::Inspector::XObject to receive the
    # invoke_xobject message and count the number of times it was
    # called, but it was only called once, so I reverted checking the
    # output with a regular expression
    @pdf.render.should =~ /(\/Stamp1 Do.*?){3}/m
  end

  it "resources added during stamp creation should be added to the "+
     "stamp XObject, not the page" do
    create_pdf
    @pdf.create_stamp("MyStamp") do
      @pdf.transparent(0.5) { @pdf.circle_at([100, 100], :radius => 10)}
    end
    @pdf.stamp("MyStamp")

    # Inspector::XObject does not give information about resources, so
    # resorting to string matching

    output = @pdf.render
    objects = output.split("endobj")
    objects.each do |object|
      if object =~ /\/Type \/Page$/
        object.should.not =~ /\/ExtGState/
      elsif object =~ /\/Type \/XObject$/
        object.should =~ /\/ExtGState/
      end
    end
  end

  it "if ProcSet changes are made, they should be added to the Page "+
     "object, not the stamp XObject" do
    create_pdf
    @pdf.create_stamp("MyStamp") do
      @pdf.text("hello")
    end
    @pdf.stamp("MyStamp")

    # Inspector::XObject does not give information about ProcSet, so
    # resorting to string matching

    output = @pdf.render
    objects = output.split("endobj")
    objects.each do |object|
      if object =~ /\/Type \/Page$/
        object.should =~ /\/ProcSet/
      elsif object =~ /\/Type \/XObject$/
        object.should.not =~ /\/ProcSet/
      end
    end
  end
end
