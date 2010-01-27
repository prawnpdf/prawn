require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "create_stamp before any page is added" do
  it "should work with the font class" do
    @pdf = Prawn::Document.new(:skip_page_creation => true)
    lambda {
      @pdf.create_stamp("my_stamp") do
        @pdf.font.height
      end
    }.should.not.raise(Prawn::Errors::NotOnPage)
  end
  it "should work with setting color" do
    @pdf = Prawn::Document.new(:skip_page_creation => true)
    lambda {
      @pdf.create_stamp("my_stamp") do
        @pdf.fill_color = 'ff0000'
      end
    }.should.not.raise(Prawn::Errors::NotOnPage)
  end
end

describe "#stamp_at" do
  it "should work" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    @pdf.stamp_at("MyStamp", [100, 200])
    # I had modified PDF::Inspector::XObject to receive the
    # invoke_xobject message and count the number of times it was
    # called, but it was only called once, so I reverted checking the
    # output with a regular expression
    @pdf.render.should =~ /\/Stamp1 Do.*?/m
  end
end

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
end
