# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "create_stamp before any page is added" do
  it "should work with the font class" do
    @pdf = Prawn::Document.new(:skip_page_creation => true)

    # If anything goes wrong, Prawn::Errors::NotOnPage will be raised
    @pdf.create_stamp("my_stamp") do
      @pdf.font.height
    end
  end

  it "should work with setting color" do
    @pdf = Prawn::Document.new(:skip_page_creation => true)

    # If anything goes wrong, Prawn::Errors::NotOnPage will be raised
    @pdf.create_stamp("my_stamp") do
      @pdf.fill_color = 'ff0000'
    end
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
  it "should raise_error NameTaken error when attempt to create stamp "+
     "with same name as an existing stamp" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    lambda {
      @pdf.create_stamp("MyStamp")
    }.should raise_error(Prawn::Errors::NameTaken)
  end

  it "should raise_error InvalidName error when attempt to create "+
     "stamp with a blank name" do
    create_pdf
    lambda {
      @pdf.create_stamp("")
    }.should raise_error(Prawn::Errors::InvalidName)
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
     "should raise_error UndefinedObjectName" do
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
      @pdf.transparent(0.5) { @pdf.circle([100, 100], 10)}
    end
    @pdf.stamp("MyStamp")

    # Inspector::XObject does not give information about resources, so
    # resorting to string matching

    output = @pdf.render
    objects = output.split("endobj")
    objects.each do |object|
      if object =~ /\/Type \/Page$/
        object.should_not =~ /\/ExtGState/
      elsif object =~ /\/Type \/XObject$/
        object.should =~ /\/ExtGState/
      end
    end
  end

  it "stamp stream should be wrapped in a graphic state" do
    create_pdf
    @pdf.create_stamp("MyStamp") do
      @pdf.text "This should have a 'q' before it and a 'Q' after it"
    end
    @pdf.stamp("MyStamp")
    stamps = PDF::Inspector::XObject.analyze(@pdf.render)
    stamps.xobject_streams[:Stamp1].data.chomp.should =~ /q(.|\s)*Q\Z/
  end

  it "should not add to the page graphic state stack " do
    create_pdf
    @pdf.state.page.stack.stack.size.should == 1

    @pdf.create_stamp("MyStamp") do
      @pdf.save_graphics_state
      @pdf.save_graphics_state
      @pdf.save_graphics_state
      @pdf.text "This should have a 'q' before it and a 'Q' after it"
      @pdf.restore_graphics_state
    end
    @pdf.state.page.stack.stack.size.should == 1
  end

  it "should be able to change fill and stroke colors within the stamp stream" do
    create_pdf
    @pdf.create_stamp("MyStamp") do
      @pdf.fill_color(100, 100, 20, 0)
      @pdf.stroke_color(100, 100, 20, 0)
    end
    @pdf.stamp("MyStamp")
    stamps = PDF::Inspector::XObject.analyze(@pdf.render)
    stamp_stream = stamps.xobject_streams[:Stamp1].data
    stamp_stream.should include("/DeviceCMYK cs\n1.000 1.000 0.200 0.000 scn")
    stamp_stream.should include("/DeviceCMYK CS\n1.000 1.000 0.200 0.000 SCN")
  end

  it "should save the color space even when same as current page color space" do
    create_pdf
    @pdf.stroke_color(100, 100, 20, 0)
    @pdf.create_stamp("MyStamp") do
      @pdf.stroke_color(100, 100, 20, 0)
    end
    @pdf.stamp("MyStamp")
    stamps = PDF::Inspector::XObject.analyze(@pdf.render)
    stamp_stream = stamps.xobject_streams[:Stamp1].data
    stamp_stream.should include("/DeviceCMYK CS\n1.000 1.000 0.200 0.000 SCN")
  end
end
