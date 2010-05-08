# encoding: utf-8
require "tempfile"

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper") 

describe "The cursor" do
  it "should equal pdf.y - bounds.absolute_bottom" do
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

describe "when generating a document from a subclass" do
  it "should be an instance of the subclass" do
    custom_document = Class.new(Prawn::Document)
    custom_document.generate(Tempfile.new("generate_test").path) do |e| 
      e.class.should == custom_document
      e.should.be.kind_of(Prawn::Document)
    end
  end

  it "should retain any extensions found on Prawn::Document" do
    mod1 = Module.new { attr_reader :test_extensions1 }
    mod2 = Module.new { attr_reader :test_extensions2 }

    Prawn::Document.extensions << mod1 << mod2

    custom_document = Class.new(Prawn::Document)
    assert_equal [mod1, mod2], custom_document.extensions

    # remove the extensions we added to prawn document
    Prawn::Document.extensions.delete(mod1)
    Prawn::Document.extensions.delete(mod2)

    assert ! Prawn::Document.new.respond_to?(:test_extensions1)
    assert ! Prawn::Document.new.respond_to?(:test_extensions2)

    # verify these still exist on custom class
    assert_equal [mod1, mod2], custom_document.extensions

    assert custom_document.new.respond_to?(:test_extensions1)
    assert custom_document.new.respond_to?(:test_extensions2)
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
      @filename = "#{Prawn::BASEDIR}/data/images/pigs.jpg"
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
    pdf.page.content.stubs(:compress_stream).returns(true)
    pdf.page.content.expects(:compress_stream).never

    pdf.text "Hi There" * 20
    pdf.render
  end

  it "should compress the page content stream if compression is enabled" do

    pdf = Prawn::Document.new(:compress => true)
    pdf.page.content.stubs(:compress_stream).returns(true)
    pdf.page.content.expects(:compress_stream).once

    pdf.text "Hi There" * 20
    pdf.render
  end

  it "should result in a smaller file size when compressed" do
    doc_uncompressed = Prawn::Document.new
    doc_compressed   = Prawn::Document.new(:compress => true)
    [doc_compressed, doc_uncompressed].each do |pdf|
       pdf.font "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"
       pdf.text "更可怕的是，同质化竞争对手可以按照URL中后面这个ID来遍历" * 10
    end

    doc_compressed.render.length.should.be < doc_uncompressed.render.length
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
    
    # MalformedPDFError raised if content stream actual length does not match
    # dictionary length
    lambda{ PDF::Inspector::Page.analyze(@pdf.render) }.
      should.not.raise(PDF::Reader::MalformedPDFError)
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
end

describe "When setting page size" do
  it "should default to LETTER" do
    @pdf = Prawn::Document.new
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.first[:size].should == Prawn::Document::PageGeometry::SIZES["LETTER"]    
  end                                                                  
  
  (Prawn::Document::PageGeometry::SIZES.keys - ["LETTER"]).each do |k|
    it "should provide #{k} geometry" do
      @pdf = Prawn::Document.new(:page_size => k)
      pages = PDF::Inspector::Page.analyze(@pdf.render).pages   
      pages.first[:size].should == Prawn::Document::PageGeometry::SIZES[k]
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
      page[:size].should == Prawn::Document::PageGeometry::SIZES["LEGAL"]
    end
  end

end       

describe "When setting page layout" do
  it "should reverse coordinates for landscape" do
    @pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages    
    pages.first[:size].should == Prawn::Document::PageGeometry::SIZES["A4"].reverse
  end   

  it "should retain page layout  by default when starting a new page" do
    @pdf = Prawn::Document.new(:page_layout => :landscape)
    @pdf.start_new_page(:trace => true)
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.each do |page|
      page[:size].should == Prawn::Document::PageGeometry::SIZES["LETTER"].reverse
    end
  end
end

describe "The mask() feature" do
  it "should allow transactional restoration of attributes" do
    @pdf = Prawn::Document.new
    y, line_width = @pdf.y, @pdf.line_width
    @pdf.mask(:y, :line_width) do
      @pdf.y = y + 1
      @pdf.line_width = line_width + 1
      @pdf.y.should.not == y
      @pdf.line_width.should.not == line_width
    end
    @pdf.y.should == y
    @pdf.line_width.should == line_width 
  end
end

describe "The group() feature" do
  it "should group a simple block on a single page" do
    pdf = Prawn::Document.new do
      self.y = 50
      group do
        text "Hello"
        text "World"
      end
    end
    pages = PDF::Inspector::Page.analyze(pdf.render).pages
    pages.size.should == 2
    pages[0][:strings].should == []
    pages[1][:strings].should == ["Hello", "World"]
  end

  it "should raise CannotGroup if the content is too tall" do
    lambda {
      Prawn::Document.new do
        group do
          100.times { text "Too long" }
        end
      end.render
    }.should.raise(Prawn::Errors::CannotGroup)
  end
end

describe "The render() feature" do
  if "spec".respond_to?(:encode!)
    it "should return a 8 bit encoded string on a m17n aware VM" do
      @pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
      @pdf.line [100,100], [200,200]
      str = @pdf.render
      str.encoding.to_s.should == "ASCII-8BIT"
    end
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

end

describe "The :optimize_objects option" do
  before(:all) do
    @wasteful_doc = lambda do
      transaction { start_new_page; text "Hidden text"; rollback }
      text "Hello world"
    end
  end

  it "should result in fewer objects when enabled" do
    wasteful_pdf = Prawn::Document.new(&@wasteful_doc)
    frugal_pdf   = Prawn::Document.new(:optimize_objects => true,
                                       &@wasteful_doc)
    frugal_pdf.render.size.should.be < wasteful_pdf.render.size
  end

  it "should default to :false" do
    default_pdf  = Prawn::Document.new(&@wasteful_doc)
    wasteful_pdf = Prawn::Document.new(:optimize_objects => false, 
                                       &@wasteful_doc)
    default_pdf.render.size.should == wasteful_pdf.render.size
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
    hash = PDF::Hash.new(output)

    streams = hash.values.select { |obj| obj.kind_of?(PDF::Reader::Stream) }

    streams.size.should == 1
  end

 it "should have 1 single content stream for a single page PDF with no templates, even if go_to_page is used" do
    @pdf = Prawn::Document.new
    @pdf.text "James"
    @pdf.go_to_page(1)
    @pdf.text "Healy"
    output = StringIO.new(@pdf.render)
    hash = PDF::Hash.new(output)

    streams = hash.values.select { |obj| obj.kind_of?(PDF::Reader::Stream) }

    streams.size.should == 1
  end
end
