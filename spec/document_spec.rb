# encoding: utf-8
require "tempfile"

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Prawn::Document.new" do
  it "should not modify its argument" do
    options = {:page_layout => :landscape}
    Prawn::Document.new(options)
    options.should == {:page_layout => :landscape}
  end
end

describe "The cursor" do
  it "should == pdf.y - bounds.absolute_bottom" do
    pdf = Prawn::Document.new
    pdf.cursor.should == pdf.bounds.top

    pdf.y = 300
    pdf.cursor.should == pdf.y - pdf.bounds.absolute_bottom
  end

  it "should be able to move relative to the bottom margin" do
    pdf = Prawn::Document.new
    pdf.move_cursor_to(10)

    pdf.cursor.should == 10
    pdf.y.should == pdf.cursor + pdf.bounds.absolute_bottom
  end
end

describe "when generating a document with a custom text formatter" do
  it "should use the provided text formatter" do
    class TestTextFormatter
      def self.format(string)
        [
          {
            text: string.gsub("Dr. Who?", "Just 'The Doctor'."),
            styles: [],
            color: nil,
            link: nil,
            anchor: nil,
            local: nil,
            font: nil,
            size: nil,
            character_spacing: nil
          }
        ]
      end
    end
    pdf = Prawn::Document.new text_formatter: TestTextFormatter
    pdf.text "Dr. Who?", inline_format: true
    text = PDF::Inspector::Text.analyze(pdf.render)
    text.strings.first.should == "Just 'The Doctor'."
  end
end

describe "when generating a document from a subclass" do
  it "should be an instance of the subclass" do
    custom_document = Class.new(Prawn::Document)
    custom_document.generate(Tempfile.new("generate_test").path) do |e|
      e.class.should == custom_document
      e.should be_a_kind_of(Prawn::Document)
    end
  end

  it "should retain any extensions found on Prawn::Document" do
    mod1 = Module.new { attr_reader :test_extensions1 }
    mod2 = Module.new { attr_reader :test_extensions2 }

    Prawn::Document.extensions << mod1 << mod2

    custom_document = Class.new(Prawn::Document)
    custom_document.extensions.should == [mod1, mod2]

    # remove the extensions we added to prawn document
    Prawn::Document.extensions.delete(mod1)
    Prawn::Document.extensions.delete(mod2)

    Prawn::Document.new.respond_to?(:test_extensions1).should be_false
    Prawn::Document.new.respond_to?(:test_extensions2).should be_false

    # verify these still exist on custom class
    custom_document.extensions.should == [mod1, mod2]

    custom_document.new.respond_to?(:test_extensions1).should be_true
    custom_document.new.respond_to?(:test_extensions2).should be_true
  end

end


describe "When creating multi-page documents" do

  before(:each) { create_pdf }

  it "should initialize with a single page" do
    page_counter = PDF::Inspector::Page.analyze(@pdf.render)

    page_counter.pages.size.should == 1
    @pdf.page_count.should == 1
  end

  it "should provide an accurate page_count" do
    3.times { @pdf.start_new_page }
    page_counter = PDF::Inspector::Page.analyze(@pdf.render)

    page_counter.pages.size.should == 4
    @pdf.page_count.should == 4
  end

end

describe "When beginning each new page" do

  describe "Background template feature" do
    before(:each) do
      @filename = "#{Prawn::DATADIR}/images/pigs.jpg"
      @pdf = Prawn::Document.new(:background => @filename)
    end
    it "should place a background image if it is in options block" do
      output = @pdf.render
      images = PDF::Inspector::XObject.analyze(output)
      # there should be 2 images in the page resources
      images.page_xobjects.first.size.should == 1
    end
    it "should place a background image if it is in options block" do
      @pdf.instance_variable_defined?(:@background).should == true
      @pdf.instance_variable_get(:@background).should == @filename
    end


  end


end

describe "Prawn::Document#float" do
  it "should restore the original y-position" do
    create_pdf
    orig_y = @pdf.y
    @pdf.float { @pdf.text "Foo" }
    @pdf.y.should == orig_y
  end

  it "should teleport across pages if necessary" do
    create_pdf

    @pdf.float do
      @pdf.text "Foo"
      @pdf.start_new_page
      @pdf.text "Bar"
    end
    @pdf.text "Baz"

    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.size.should == 2
    pages[0][:strings].should == ["Foo", "Baz"]
    pages[1][:strings].should == ["Bar"]
  end
end

describe "The page_number method" do
  it "should be 1 for a new document" do
    pdf = Prawn::Document.new
    pdf.page_number.should == 1
  end

  it "should be 0 for documents with no pages" do
    pdf = Prawn::Document.new(:skip_page_creation => true)
    pdf.page_number.should == 0
  end

  it "should be changed by go_to_page" do
    pdf = Prawn::Document.new
    10.times { pdf.start_new_page }
    pdf.go_to_page 3
    pdf.page_number.should == 3
  end

end

describe "on_page_create callback" do
  before do
    create_pdf
  end

  it "should be invoked with document" do
    called_with = nil

    @pdf.on_page_create { |*args| called_with = args }

    @pdf.start_new_page

    called_with.should == [@pdf]
  end

  it "should be invoked for each new page" do
    trigger = mock()
    trigger.expects(:fire).times(5)

    @pdf.on_page_create { trigger.fire }

    5.times { @pdf.start_new_page }
  end

  it "should be replaceable" do
      trigger1 = mock()
      trigger1.expects(:fire).times(1)

      trigger2 = mock()
      trigger2.expects(:fire).times(1)

      @pdf.on_page_create { trigger1.fire }

      @pdf.start_new_page

      @pdf.on_page_create { trigger2.fire }

      @pdf.start_new_page
  end

  it "should be clearable by calling on_page_create without a block" do
      trigger = mock()
      trigger.expects(:fire).times(1)

      @pdf.on_page_create { trigger.fire }

      @pdf.start_new_page

      @pdf.on_page_create

      @pdf.start_new_page
  end

end

describe "Document compression" do

  it "should not compress the page content stream if compression is disabled" do

    pdf = Prawn::Document.new(:compress => false)
    pdf.page.content.stream.stubs(:compress!).returns(true)
    pdf.page.content.stream.expects(:compress!).never

    pdf.text "Hi There" * 20
    pdf.render
  end

  it "should compress the page content stream if compression is enabled" do

    pdf = Prawn::Document.new(:compress => true)
    pdf.page.content.stream.stubs(:compress!).returns(true)
    pdf.page.content.stream.expects(:compress!).once

    pdf.text "Hi There" * 20
    pdf.render
  end

  it "should result in a smaller file size when compressed" do
    doc_uncompressed = Prawn::Document.new
    doc_compressed   = Prawn::Document.new(:compress => true)
    [doc_compressed, doc_uncompressed].each do |pdf|
       pdf.font "#{Prawn::DATADIR}/fonts/gkai00mp.ttf"
       pdf.text "更可怕的是，同质化竞争对手可以按照URL中后面这个ID来遍历" * 10
    end

    doc_compressed.render.length.should be < doc_uncompressed.render.length
  end

end

describe "Document metadata" do
  it "should output strings as UTF-16 with a byte order mark" do
    pdf = Prawn::Document.new(:info => {:Author => "Lóránt"})
    pdf.state.store.info.object.should =~
      # UTF-16:     BOM L   ó   r   á   n   t
      %r{/Author\s*<feff004c00f3007200e1006e0074>}i
  end
end

describe "When reopening pages" do
  it "should modify the content stream size" do
    @pdf = Prawn::Document.new do |pdf|
      pdf.text "Page 1"
      pdf.start_new_page
      pdf.text "Page 2"
      pdf.go_to_page 1
      pdf.text "More for page 1"
    end

    # Indirectly verify that the actual length does not match dictionary length.
    # If it isn't, a MalformedPDFError will be raised
    PDF::Inspector::Page.analyze(@pdf.render)
  end

  it "should insert pages after the current page when calling start_new_page" do
    pdf = Prawn::Document.new
    3.times { |i| pdf.text "Old page #{i+1}"; pdf.start_new_page }
    pdf.go_to_page 1
    pdf.start_new_page
    pdf.text "New page 2"

    pdf.page_number.should == 2

    pages = PDF::Inspector::Page.analyze(pdf.render).pages
    pages.size.should == 5
    pages[1][:strings].should == ["New page 2"]
    pages[2][:strings].should == ["Old page 2"]
  end

  it "should update the bounding box to the new page's margin box" do
    Prawn::Document.new do
      start_new_page :layout => :landscape
      lsize = [bounds.width, bounds.height]
      go_to_page 1
      [bounds.width, bounds.height].should == lsize.reverse
    end
  end
end

describe "When setting page size" do
  it "should default to LETTER" do
    @pdf = Prawn::Document.new
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.first[:size].should == PDF::Core::PageGeometry::SIZES["LETTER"]
  end

  (PDF::Core::PageGeometry::SIZES.keys - ["LETTER"]).each do |k|
    it "should provide #{k} geometry" do
      @pdf = Prawn::Document.new(:page_size => k)
      pages = PDF::Inspector::Page.analyze(@pdf.render).pages
      pages.first[:size].should == PDF::Core::PageGeometry::SIZES[k]
    end
  end

  it "should allow custom page size" do
    @pdf = Prawn::Document.new(:page_size => [1920, 1080] )
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.first[:size].should == [1920, 1080]
  end


  it "should retain page size by default when starting a new page" do
    @pdf = Prawn::Document.new(:page_size => "LEGAL")
    @pdf.start_new_page
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.each do |page|
      page[:size].should == PDF::Core::PageGeometry::SIZES["LEGAL"]
    end
  end

end

describe "When setting page layout" do
  it "should reverse coordinates for landscape" do
    @pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.first[:size].should == PDF::Core::PageGeometry::SIZES["A4"].reverse
  end

  it "should retain page layout by default when starting a new page" do
    @pdf = Prawn::Document.new(:page_layout => :landscape)
    @pdf.start_new_page(:trace => true)
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.each do |page|
      page[:size].should == PDF::Core::PageGeometry::SIZES["LETTER"].reverse
    end
  end

  it "should swap the bounds when starting a new page with different layout" do
    @pdf = Prawn::Document.new
    size = [@pdf.bounds.width, @pdf.bounds.height]
    @pdf.start_new_page(:layout => :landscape)
    [@pdf.bounds.width, @pdf.bounds.height].should == size.reverse
  end
end

describe "The mask() feature" do
  it "should allow transactional restoration of attributes" do
    @pdf = Prawn::Document.new
    y, line_width = @pdf.y, @pdf.line_width
    @pdf.mask(:y, :line_width) do
      @pdf.y = y + 1
      @pdf.line_width = line_width + 1
      @pdf.y.should_not == y
      @pdf.line_width.should_not == line_width
    end
    @pdf.y.should == y
    @pdf.line_width.should == line_width
  end
end

describe "The group() feature" do
  xit "should return a true value if the content fits on one page" do
    pdf = Prawn::Document.new do
      val = group { text "Hello"; text "World" }
      (!!val).should == true
    end
  end

  xit "should group a simple block on a single page" do
    pdf = Prawn::Document.new do
      self.y = 50
      val = group do
        text "Hello"
        text "World"
      end

      # group should return a false value since a new page was started
      (!!val).should == false
    end
    pages = PDF::Inspector::Page.analyze(pdf.render).pages
    pages.size.should == 2
    pages[0][:strings].should == []
    pages[1][:strings].should == ["Hello", "World"]
  end

  xit "should raise_error CannotGroup if the content is too tall" do
    lambda {
      Prawn::Document.new do
        group do
          100.times { text "Too long" }
        end
      end.render
    }.should raise_error(Prawn::Errors::CannotGroup)
  end

   xit "should group within individual column boxes" do
    pdf = Prawn::Document.new do
      # Set up columns with grouped blocks of 0..49. 0 to 49 is slightly short
      # of the height of one page / column, so each column should get its own
      # group (every column should start with zero).
      column_box([0, bounds.top], :width => bounds.width, :columns => 7) do
        10.times do
          group { 50.times { |i| text(i.to_s) } }
        end
      end
    end

    # Second page should start with a 0 because it's a new group.
    pages = PDF::Inspector::Page.analyze(pdf.render).pages
    pages.size.should == 2
    pages[1][:strings].first.should == '0'
  end

end

describe "The render() feature" do
  it "should return a 8 bit encoded string on a m17n aware VM" do
    @pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    @pdf.line [100,100], [200,200]
    str = @pdf.render
    str.encoding.to_s.should == "ASCII-8BIT"
  end

  it "should trigger before_render callbacks just before rendering" do
    pdf = Prawn::Document.new

    seq = sequence("callback_order")

    # Verify the order: finalize -> fire callbacks -> render body
    pdf.expects(:finalize_all_page_contents).in_sequence(seq)
    trigger = mock()
    trigger.expects(:fire).in_sequence(seq)

    # Store away the render_body method to be called below
    render_body = pdf.method(:render_body)
    pdf.expects(:render_body).in_sequence(seq)

    pdf.before_render{ trigger.fire }

    # Render the body to set up object offsets
    render_body.call(StringIO.new)
    pdf.render
  end

  it "should be idempotent" do
    pdf = Prawn::Document.new

    contents  = pdf.render
    contents2 = pdf.render
    contents2.should == contents
  end
end

describe "PDF file versions" do
  it "should default to 1.3" do
    @pdf = Prawn::Document.new
    str = @pdf.render
    str[0,8].should == "%PDF-1.3"
  end

  it "should allow the default to be changed" do
    @pdf = Prawn::Document.new
    @pdf.__send__(:min_version, 1.4)
    str = @pdf.render
    str[0,8].should == "%PDF-1.4"
  end
end

describe "Documents that use go_to_page" do
 it "should have 2 pages after calling start_new_page and go_to_page" do
    @pdf = Prawn::Document.new
    @pdf.text "James"
    @pdf.start_new_page
    @pdf.text "Anthony"
    @pdf.go_to_page(1)
    @pdf.text "Healy"

    page_counter = PDF::Inspector::Page.analyze(@pdf.render)
    page_counter.pages.size.should == 2
  end

  it "should correctly add text to pages" do
    @pdf = Prawn::Document.new
    @pdf.text "James"
    @pdf.start_new_page
    @pdf.text "Anthony"
    @pdf.go_to_page(1)
    @pdf.text "Healy"

    text = PDF::Inspector::Text.analyze(@pdf.render)

    text.strings.size.should == 3
    text.strings.include?("James").should == true
    text.strings.include?("Anthony").should == true
    text.strings.include?("Healy").should == true
  end
end

describe "content stream characteristics" do
 it "should have 1 single content stream for a single page PDF with no templates" do
    @pdf = Prawn::Document.new
    @pdf.text "James"
    output = StringIO.new(@pdf.render)
    hash = PDF::Reader::ObjectHash.new(output)

    streams = hash.values.select { |obj| obj.kind_of?(PDF::Reader::Stream) }

    streams.size.should == 1
  end

 it "should have 1 single content stream for a single page PDF with no templates, even if go_to_page is used" do
    @pdf = Prawn::Document.new
    @pdf.text "James"
    @pdf.go_to_page(1)
    @pdf.text "Healy"
    output = StringIO.new(@pdf.render)
    hash = PDF::Reader::ObjectHash.new(output)

    streams = hash.values.select { |obj| obj.kind_of?(PDF::Reader::Stream) }

    streams.size.should == 1
  end
end

describe "The number_pages method" do
  before do
    @pdf = Prawn::Document.new(:skip_page_creation => true)
  end

  it "replaces the '<page>' string with the proper page number" do
    @pdf.start_new_page
    @pdf.expects(:text_box).with("1, test", { :height => 50 })
    @pdf.number_pages "<page>, test", {:page_filter => :all}
  end

  it "replaces the '<total>' string with the total page count" do
    @pdf.start_new_page
    @pdf.expects(:text_box).with("test, 1", { :height => 50 })
    @pdf.number_pages "test, <total>", {:page_filter => :all}
  end

  it "must print each page if given the :all page_filter" do
    10.times { @pdf.start_new_page }
    @pdf.expects(:text_box).times(10)
    @pdf.number_pages "test", {:page_filter => :all}
  end

  it "must print each page if no :page_filter is specified" do
    10.times { @pdf.start_new_page }
    @pdf.expects(:text_box).times(10)
    @pdf.number_pages "test"
  end

  it "must not print the page number if given a nil filter" do
    10.times { @pdf.start_new_page }
    @pdf.expects(:text_box).never
    @pdf.number_pages "test", {:page_filter => nil}
  end

  context "start_count_at option" do
    [1, 2].each do |startat|
      context "equal to #{startat}" do
        it "increments the pages" do
          2.times { @pdf.start_new_page }
          options = {:page_filter => :all, :start_count_at => startat}
          @pdf.expects(:text_box).with("#{startat} 2", { :height => 50 })
          @pdf.expects(:text_box).with("#{startat+1} 2", { :height => 50 })
          @pdf.number_pages "<page> <total>", options
        end
      end
    end

    [0, nil].each do |val|
      context "equal to #{val}" do
        it "defaults to start at page 1" do
          3.times { @pdf.start_new_page }
          options = {:page_filter => :all, :start_count_at => val}
          @pdf.expects(:text_box).with("1 3", { :height => 50 })
          @pdf.expects(:text_box).with("2 3", { :height => 50 })
          @pdf.expects(:text_box).with("3 3", { :height => 50 })
          @pdf.number_pages "<page> <total>", options
        end
      end
    end
  end

  context "total_pages option" do
    it "allows the total pages count to be overridden" do
      2.times { @pdf.start_new_page }
      @pdf.expects(:text_box).with("1 10", { :height => 50 })
      @pdf.expects(:text_box).with("2 10", { :height => 50 })
      @pdf.number_pages "<page> <total>", :page_filter => :all, :total_pages => 10
    end
  end

  context "special page filter" do
    context "such as :odd" do
      it "increments the pages" do
        3.times { @pdf.start_new_page }
        @pdf.expects(:text_box).with("1 3", { :height => 50 })
        @pdf.expects(:text_box).with("3 3", { :height => 50 })
        @pdf.expects(:text_box).with("2 3", { :height => 50 }).never
        @pdf.number_pages "<page> <total>", :page_filter => :odd
      end
    end
    context "missing" do
      it "does not print any page numbers" do
        3.times { @pdf.start_new_page }
        @pdf.expects(:text_box).never
        @pdf.number_pages "<page> <total>", :page_filter => nil
      end
    end
  end

  context "given both a special page filter and a start_count_at parameter" do
    context "such as :odd and 7" do
      it "increments the pages" do
        3.times { @pdf.start_new_page }
        @pdf.expects(:text_box).with("1 3", { :height => 50 }).never
        @pdf.expects(:text_box).with("5 3", { :height => 50 }) # page 1
        @pdf.expects(:text_box).with("6 3", { :height => 50 }).never # page 2
        @pdf.expects(:text_box).with("7 3", { :height => 50 }) # page 3
        @pdf.number_pages "<page> <total>", :page_filter => :odd, :start_count_at => 5
      end
    end
    context "some crazy proc and 2" do
      it "increments the pages" do
        6.times { @pdf.start_new_page }
        options = {:page_filter => lambda {|p| p != 2 && p != 5}, :start_count_at => 4}
        @pdf.expects(:text_box).with("4 6", { :height => 50 }) # page 1
        @pdf.expects(:text_box).with("5 6", { :height => 50 }).never # page 2
        @pdf.expects(:text_box).with("6 6", { :height => 50 }) # page 3
        @pdf.expects(:text_box).with("7 6", { :height => 50 }) # page 4
        @pdf.expects(:text_box).with("8 6", { :height => 50 }).never # page 5
        @pdf.expects(:text_box).with("9 6", { :height => 50 }) # page 6
        @pdf.number_pages "<page> <total>", options
      end
    end
  end

  context "height option" do
    before do
      @pdf.start_new_page
    end

    it "with 10 height" do
      @pdf.expects(:text_box).with("1 1", { :height => 10 })
      @pdf.number_pages "<page> <total>", :height => 10
    end

    it "with nil height" do
      @pdf.expects(:text_box).with("1 1", { :height => nil })
      @pdf.number_pages "<page> <total>", :height => nil
    end

    it "with no height" do
      @pdf.expects(:text_box).with("1 1", { :height => 50 })
      @pdf.number_pages "<page> <total>"
    end
  end
end

describe "The page_match? method" do
  before do
    @pdf = Prawn::Document.new(:skip_page_creation => true)
    10.times {@pdf.start_new_page}
  end

  it "returns nil given no filter" do
    @pdf.page_match?(:nil, 1).should be_false
  end

  it "must provide an :all filter" do
    (1..@pdf.page_count).all? { |i| @pdf.page_match?(:all, i) }.should be_true
  end

  it "must provide an :odd filter" do
    odd, even = (1..@pdf.page_count).partition { |e| e % 2 == 1 }
    odd.all? { |i| @pdf.page_match?(:odd, i) }.should be_true
    even.any? { |i| @pdf.page_match?(:odd, i) }.should be_false
  end

  it "must be able to filter by an array of page numbers" do
    fltr = [1,2,7]
    (1..10).select { |i| @pdf.page_match?(fltr, i) }.should == [1,2,7]
  end

  it "must be able to filter by a range of page numbers" do
    fltr = 2..4
    (1..10).select { |i| @pdf.page_match?(fltr, i) }.should == [2,3,4]
  end

  it "must be able to filter by an arbitrary proc" do
    fltr = lambda { |x| x == 1 or x % 3 == 0 }
    (1..10).select { |i| @pdf.page_match?(fltr, i) }.should == [1,3,6,9]
  end
end
