require_relative "spec_helper"
require_relative "../lib/prawn/templates"

describe "Document built from a template" do
  it "should have the same page count as the source document" do
    filename = "#{Prawn::BASEDIR}/spec/data/curves.pdf"
    @pdf = Prawn::Document.new(:template => filename)
    page_counter = PDF::Inspector::Page.analyze(@pdf.render)

    page_counter.pages.size.should == 1
  end

  it "should not set the template page's parent to the document pages catalog (especially with nested pages)" do
    filename = "#{Prawn::DATADIR}/pdfs/nested_pages.pdf"
    @pdf = Prawn::Document.new(:template => filename, :skip_page_creation => true)
    @pdf.state.page.dictionary.data[:Parent].should_not == @pdf.state.store.pages
  end


  it "should have start with the Y cursor at the top of the document" do
    filename = "#{Prawn::BASEDIR}/spec/data/curves.pdf"

    @pdf = Prawn::Document.new(:template => filename)
    (@pdf.y == nil).should == false
  end

  it "should respect margins set by Prawn" do
    filename = "#{Prawn::BASEDIR}/spec/data/curves.pdf"

    @pdf = Prawn::Document.new(:template => filename, :margin => 0)
    @pdf.page.margins.should == { :left   => 0,
                                  :right  => 0,
                                  :top    => 0,
                                  :bottom => 0 }

    @pdf = Prawn::Document.new(:template => filename, :left_margin => 0)

    @pdf.page.margins.should == { :left   => 0,
                                  :right  => 36,
                                  :top    => 36,
                                  :bottom => 36 }

    @pdf.start_new_page(:right_margin => 0)

    @pdf.page.margins.should == { :left   => 0,
                                  :right  => 0,
                                  :top    => 36,
                                  :bottom => 36 }



  end

  it "should not add an extra restore_graphics_state operator to the end of any content stream" do
    filename = "#{Prawn::BASEDIR}/spec/data/curves.pdf"

    @pdf = Prawn::Document.new(:template => filename)
    output = StringIO.new(@pdf.render)
    hash = PDF::Reader::ObjectHash.new(output)

    hash.each_value do |obj|
      next unless obj.kind_of?(PDF::Reader::Stream)

      data = obj.data.tr(" \n\r","")
      data.include?("QQ").should == false
    end
  end

  it "should have a single page object if importing a single page template" do
    filename = "#{Prawn::DATADIR}/pdfs/hexagon.pdf"

    @pdf = Prawn::Document.new(:template => filename)
    output = StringIO.new(@pdf.render)
    hash = PDF::Reader::ObjectHash.new(output)

    pages = hash.values.select { |obj| obj.kind_of?(Hash) && obj[:Type] == :Page }

    pages.size.should == 1
  end

  it "should have two content streams if importing a single page template" do
    filename = "#{Prawn::DATADIR}/pdfs/hexagon.pdf"

    @pdf = Prawn::Document.new(:template => filename)
    output = StringIO.new(@pdf.render)
    hash = PDF::Reader::ObjectHash.new(output)

    streams = hash.values.select { |obj| obj.kind_of?(PDF::Reader::Stream) }

    streams.size.should == 2
  end

  it "should not die if using this PDF as a template" do
    filename = "#{Prawn::DATADIR}/pdfs/complex_template.pdf"

    lambda {
      @pdf = Prawn::Document.new(:template => filename)
    }.should_not raise_error
  end


  it "should have balance q/Q operators on all content streams" do
    filename = "#{Prawn::DATADIR}/pdfs/hexagon.pdf"

    @pdf = Prawn::Document.new(:template => filename)
    output = StringIO.new(@pdf.render)
    hash = PDF::Reader::ObjectHash.new(output)

    streams = hash.values.select { |obj| obj.kind_of?(PDF::Reader::Stream) }

    streams.each do |stream|
      data = stream.unfiltered_data
      data.scan("q").size.should == 1
      data.scan("Q").size.should == 1
    end
  end

  it "should allow text to be added to a single page template" do
    filename = "#{Prawn::DATADIR}/pdfs/hexagon.pdf"

    @pdf = Prawn::Document.new(:template => filename)

    @pdf.text "Adding some text"

    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.first.should == "Adding some text"
  end

  it "should allow PDFs with page resources behind an indirect object to be used as templates" do
    filename = "#{Prawn::DATADIR}/pdfs/resources_as_indirect_object.pdf"

    @pdf = Prawn::Document.new(:template => filename)

    @pdf.text "Adding some text"

    text = PDF::Inspector::Text.analyze(@pdf.render)
    all_text = text.strings.join
    all_text.include?("Adding some text").should == true
  end

  it "should copy the PDF version from the template file" do
    filename = "#{Prawn::DATADIR}/pdfs/version_1_6.pdf"

    @pdf = Prawn::Document.new(:template => filename)
    str = @pdf.render
    str[0,8].should == "%PDF-1.6"
  end

  it "should correctly add a TTF font to a template that has existing fonts" do
    filename = "#{Prawn::DATADIR}/pdfs/contains_ttf_font.pdf"
    @pdf = Prawn::Document.new(:template => filename)
    @pdf.font "#{Prawn::DATADIR}/fonts/Chalkboard.ttf"
    @pdf.move_down(40)
    @pdf.text "Hi There"

    output = StringIO.new(@pdf.render)
    hash = PDF::Reader::ObjectHash.new(output)

    page_dict = hash.values.detect{ |obj| obj.is_a?(Hash) && obj[:Type] == :Page }
    resources = page_dict[:Resources]
    fonts = resources[:Font]
    fonts.size.should == 2
  end

  it "should correctly import a template file that is missing a MediaBox entry" do
    filename = "#{Prawn::DATADIR}/pdfs/page_without_mediabox.pdf"

    @pdf = Prawn::Document.new(:template => filename)
    str = @pdf.render
    str[0,4].should == "%PDF"
  end

  context "with the template as a stream" do
    it "should correctly import a template file from a stream" do
      filename = "#{Prawn::DATADIR}/pdfs/hexagon.pdf"
      io = StringIO.new(File.binread(filename))
      @pdf = Prawn::Document.new(:template => io)
      str = @pdf.render
      str[0,4].should == "%PDF"
    end
  end

  it "merges metadata info" do
    filename = "#{Prawn::DATADIR}/pdfs/hexagon.pdf"
    info = { :Title => "Sample METADATA",
             :Author => "Me",
             :Subject => "Not Working",
             :CreationDate => Time.now }

    @pdf = Prawn::Document.new(:template => filename, :info => info)
    output = StringIO.new(@pdf.render)
    hash = PDF::Reader::ObjectHash.new(output)
    info.keys.each { |k| hash[hash.trailer[:Info]].keys.include?(k).should == true }
  end

end

describe "Document#start_new_page with :template option" do
  filename = "#{Prawn::BASEDIR}/spec/data/curves.pdf"

  it "should set the imported page's parent to the document pages catalog" do
    @pdf = Prawn::Document.new()
    @pdf.start_new_page(:template => filename)
    @pdf.state.page.dictionary.data[:Parent].should == @pdf.state.store.pages
  end

  it "should set start the Y cursor at the top of the page" do
    @pdf = Prawn::Document.new()
    @pdf.start_new_page(:template => filename)
    (@pdf.y == nil).should == false
  end

  it "should respect margins set by Prawn" do
    @pdf = Prawn::Document.new(:margin => 0)
    @pdf.start_new_page(:template => filename)
    @pdf.page.margins.should == { :left   => 0,
                                  :right  => 0,
                                  :top    => 0,
                                  :bottom => 0 }

    @pdf = Prawn::Document.new(:left_margin => 0)
    @pdf.start_new_page(:template => filename)
    @pdf.page.margins.should == { :left   => 0,
                                  :right  => 36,
                                  :top    => 36,
                                  :bottom => 36 }
    @pdf.start_new_page(:template => filename, :right_margin => 0)
    @pdf.page.margins.should == { :left   => 0,
                                  :right  => 0,
                                  :top    => 36,
                                  :bottom => 36 }
  end

  it "should not add an extra restore_graphics_state operator to the end of any content stream" do
    @pdf = Prawn::Document.new
    @pdf.start_new_page(:template => filename)
    output = StringIO.new(@pdf.render)
    hash = PDF::Reader::ObjectHash.new(output)

    hash.each_value do |obj|
      next unless obj.kind_of?(PDF::Reader::Stream)

      data = obj.data.tr(" \n\r","")
      data.include?("QQ").should == false
    end
  end

  it "should have two content streams if importing a single page template" do
    filename = "#{Prawn::DATADIR}/pdfs/hexagon.pdf"
    @pdf = Prawn::Document.new()
    @pdf.start_new_page(:template => filename)
    output = StringIO.new(@pdf.render)
    hash = PDF::Reader::ObjectHash.new(output)
    pages = hash.values.find {|obj| obj.is_a?(Hash) && obj[:Type] == :Pages}[:Kids]
    template_page = hash[pages[1]]
    template_page[:Contents].size.should == 2
  end

  it "should have balance q/Q operators on all content streams" do
    filename = "#{Prawn::DATADIR}/pdfs/hexagon.pdf"

    @pdf = Prawn::Document.new()
    @pdf.start_new_page(:template => filename)
    output = StringIO.new(@pdf.render)
    hash = PDF::Reader::ObjectHash.new(output)

    streams = hash.values.select { |obj| obj.kind_of?(PDF::Reader::Stream) }

    streams.each do |stream|
      data = stream.unfiltered_data
      data.scan("q").size.should == 1
      data.scan("Q").size.should == 1
    end
  end

  it "should allow text to be added to a single page template" do

    @pdf = Prawn::Document.new()
    @pdf.start_new_page(:template => filename)

    @pdf.text "Adding some text"

    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.first.should == "Adding some text"
  end

  it "should allow PDFs with page resources behind an indirect object to be used as templates" do
    filename = "#{Prawn::DATADIR}/pdfs/resources_as_indirect_object.pdf"

    @pdf = Prawn::Document.new()
    @pdf.start_new_page(:template => filename)

    @pdf.text "Adding some text"

    text = PDF::Inspector::Text.analyze(@pdf.render)
    all_text = text.strings.join
    all_text.include?("Adding some text").should == true
  end

  it "should correctly add a TTF font to a template that has existing fonts" do
    filename = "#{Prawn::DATADIR}/pdfs/contains_ttf_font.pdf"
    @pdf = Prawn::Document.new()
    @pdf.start_new_page(:template => filename)
    @pdf.font "#{Prawn::DATADIR}/fonts/Chalkboard.ttf"
    @pdf.move_down(40)
    @pdf.text "Hi There"

    output = StringIO.new(@pdf.render)
    hash = PDF::Reader::ObjectHash.new(output)
    hash = PDF::Reader::ObjectHash.new(output)
    pages = hash.values.find {|obj| obj.is_a?(Hash) && obj[:Type] == :Pages}[:Kids]
    template_page = hash[pages[1]]
    resources = template_page[:Resources]
    fonts = resources[:Font]
    fonts.size.should == 2
  end

  it "indexes template pages when used multiple times" do
    filename = "#{Prawn::DATADIR}/pdfs/multipage_template.pdf"
    @repeated_pdf = Prawn::Document.new()
    3.times { @repeated_pdf.start_new_page(:template => filename) }
    repeated_hash = PDF::Reader::ObjectHash.new(StringIO.new(@repeated_pdf.render))
    @sequential_pdf = Prawn::Document.new()
    (1..3).each { |p| @sequential_pdf.start_new_page(:template => filename, :template_page => p ) }
    sequential_hash = PDF::Reader::ObjectHash.new(StringIO.new(@sequential_pdf.render))
    (repeated_hash.size < sequential_hash.size).should == true
  end

  context "with the template as a stream" do
    it "should correctly import a template file from a stream" do
      filename = "#{Prawn::DATADIR}/pdfs/hexagon.pdf"
      io = StringIO.new(File.binread(filename))

      @pdf = Prawn::Document.new()
      @pdf.start_new_page(:template => io)

      str = @pdf.render
      str[0,4].should == "%PDF"
    end
  end

  context "using template_page option" do
    it "uses the specified page option" do
      filename = "#{Prawn::DATADIR}/pdfs/multipage_template.pdf"
      @pdf = Prawn::Document.new()
      @pdf.start_new_page(:template => filename, :template_page => 2)
      text = PDF::Inspector::Text.analyze(@pdf.render)
      text.strings.first.should == "This is template page 2"
    end
  end
end

describe "ObjectStore extensions" do
  before(:each) do
    @store = PDF::Core::ObjectStore.new
  end

  it "should import objects from an existing PDF" do
    filename = "#{Prawn::BASEDIR}/spec/data/curves.pdf"
    store = PDF::Core::ObjectStore.new(:template => filename)
    store.size.should == 5
  end

  it "should point to existing roots when importing objects from an existing PDF" do
    filename = "#{Prawn::BASEDIR}/spec/data/curves.pdf"
    store = PDF::Core::ObjectStore.new(:template => filename)
    store.info.class.should == PDF::Core::Reference
    store.root.class.should == PDF::Core::Reference
  end

  it "should initialize with pages when importing objects from an existing PDF" do
    filename = "#{Prawn::BASEDIR}/spec/data/curves.pdf"
    store = PDF::Core::ObjectStore.new(:template => filename)
    store.pages.data[:Count].should == 1
  end

  it "should import all objects from a PDF that has an indirect reference in a stream dict" do
    filename = "#{Prawn::DATADIR}/pdfs/indirect_reference.pdf"
    store = PDF::Core::ObjectStore.new(:template => filename)
    store.size.should == 8
  end

  it "should raise_error ArgumentError when given a file that doesn exist as a template" do
    filename = "not_really_there.pdf"

    lambda { PDF::Core::ObjectStore.new(:template => filename) }.should raise_error(ArgumentError)
  end

  it "should raise_error PDF::Core::Errors::TemplateError when given a non PDF as a template" do
    filename = "#{Prawn::DATADIR}/images/dice.png"

    lambda { PDF::Core::ObjectStore.new(:template => filename) }.should raise_error(PDF::Core::Errors::TemplateError)
  end

  it "should raise_error PDF::Core::Errors::TemplateError when given an encrypted PDF as a template" do
    filename = "#{Prawn::DATADIR}/pdfs/encrypted.pdf"

    lambda { PDF::Core::ObjectStore.new(:template => filename) }.should raise_error(PDF::Core::Errors::TemplateError)
  end
end

describe "ObjectStore#object_id_for_page" do
  it "should return the object ID of an imported template page" do
    filename = "#{Prawn::DATADIR}/pdfs/hexagon.pdf"
    store = PDF::Core::ObjectStore.new(:template => filename)
    store.object_id_for_page(0).should == 4
  end

  it "should return the object ID of the first imported template page" do
    filename = "#{Prawn::DATADIR}/pdfs/two_hexagons.pdf"
    store = PDF::Core::ObjectStore.new(:template => filename)
    store.object_id_for_page(1).should == 4
  end

  it "should return the object ID of the last imported template page" do
    filename = "#{Prawn::DATADIR}/pdfs/two_hexagons.pdf"
    store = PDF::Core::ObjectStore.new(:template => filename)
    store.object_id_for_page(-1).should == 6
  end

  it "should return the object ID of the first page of a template that uses nested Pages" do
    filename = "#{Prawn::DATADIR}/pdfs/nested_pages.pdf"
    store = PDF::Core::ObjectStore.new(:template => filename)
    store.object_id_for_page(1).should == 5
  end

  it "should return the object ID of the last page of a template that uses nested Pages" do
    filename = "#{Prawn::DATADIR}/pdfs/nested_pages.pdf"
    store = PDF::Core::ObjectStore.new(:template => filename)
    store.object_id_for_page(-1).should == 8
  end

  it "should return nil if given an invalid page number" do
    filename = "#{Prawn::DATADIR}/pdfs/hexagon.pdf"
    store = PDF::Core::ObjectStore.new(:template => filename)
    store.object_id_for_page(10).should == nil
  end

  it "should return nil if given an invalid page number" do
    store = PDF::Core::ObjectStore.new
    store.object_id_for_page(10).should == nil
  end

  it "should accept a stream instead of a filename" do
    example = Prawn::Document.new()
    example.text "An example doc, created in memory"
    example.start_new_page
    StringIO.open(example.render) do |stream|
      @pdf = PDF::Core::ObjectStore.new(:template => stream)
    end
    @pdf.page_count.should == 2
  end
end
