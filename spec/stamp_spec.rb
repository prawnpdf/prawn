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
    expect(@pdf.render).to match(/\/Stamp1 Do.*?/m)
  end
end

describe "Document with a stamp" do
  it "should raise_error NameTaken error when attempt to create stamp " \
     "with same name as an existing stamp" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    expect {
      @pdf.create_stamp("MyStamp")
    }.to raise_error(Prawn::Errors::NameTaken)
  end

  it "should raise_error InvalidName error when attempt to create " \
     "stamp with a blank name" do
    create_pdf
    expect {
      @pdf.create_stamp("")
    }.to raise_error(Prawn::Errors::InvalidName)
  end

  it "a new XObject should be defined for each stamp created" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    @pdf.create_stamp("AnotherStamp")
    @pdf.stamp("MyStamp")
    @pdf.stamp("AnotherStamp")

    inspector = PDF::Inspector::XObject.analyze(@pdf.render)
    xobjects = inspector.page_xobjects.last
    expect(xobjects.length).to eq(2)
  end

  it "calling stamp with a name that does not match an existing stamp " \
     "should raise_error UndefinedObjectName" do
    create_pdf
    @pdf.create_stamp("MyStamp")
    expect {
      @pdf.stamp("OtherStamp")
    }.to raise_error(Prawn::Errors::UndefinedObjectName)
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
    expect(@pdf.render).to match(/(\/Stamp1 Do.*?){3}/m)
  end

  it "stamp should render clickable links" do
    create_pdf
    @pdf.create_stamp 'bar' do
      @pdf.text '<b>Prawn</b> <link href="http://github.com">GitHub</link>', inline_format: true
    end
    @pdf.stamp 'bar'

    output = @pdf.render
    objects = output.split("endobj")

    objects.each do |obj|
      if obj =~ /\/Type \/Page$/
        # The page object must contain the annotation reference
        # to render a clickable link
        expect(obj).to match(/^\/Annots \[\d \d .\]$/)
      end
    end
  end

  it "resources added during stamp creation should be added to the " \
     "stamp XObject, not the page" do
    create_pdf
    @pdf.create_stamp("MyStamp") do
      @pdf.transparent(0.5) { @pdf.circle([100, 100], 10) }
    end
    @pdf.stamp("MyStamp")

    # Inspector::XObject does not give information about resources, so
    # resorting to string matching

    output = @pdf.render
    objects = output.split("endobj")
    objects.each do |object|
      if object =~ /\/Type \/Page$/
        expect(object).not_to match(/\/ExtGState/)
      elsif object =~ /\/Type \/XObject$/
        expect(object).to match(/\/ExtGState/)
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
    expect(stamps.xobject_streams[:Stamp1].data.chomp).to match(/q(.|\s)*Q\Z/)
  end

  it "should not add to the page graphic state stack " do
    create_pdf
    expect(@pdf.state.page.stack.stack.size).to eq(1)

    @pdf.create_stamp("MyStamp") do
      @pdf.save_graphics_state
      @pdf.save_graphics_state
      @pdf.save_graphics_state
      @pdf.text "This should have a 'q' before it and a 'Q' after it"
      @pdf.restore_graphics_state
    end
    expect(@pdf.state.page.stack.stack.size).to eq(1)
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
    expect(stamp_stream).to include("/DeviceCMYK cs\n1.000 1.000 0.200 0.000 scn")
    expect(stamp_stream).to include("/DeviceCMYK CS\n1.000 1.000 0.200 0.000 SCN")
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
    expect(stamp_stream).to include("/DeviceCMYK CS\n1.000 1.000 0.200 0.000 SCN")
  end
end
