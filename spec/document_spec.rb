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
  it "should be an instance_eval of the subclass" do
    custom_document = Class.new(Prawn::Document)
    custom_document.generate(Tempfile.new("generate_test").path) do |e| 
      e.class.should == custom_document
      e.should.be.kind_of(Prawn::Document)
    end
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

describe "When ending each page" do

  it "should not compress the page content stream if compression is disabled" do

    pdf = Prawn::Document.new(:compress => false)
    content_stub = pdf.ref!({})
    content_stub.stubs(:compress_stream).returns(true)
    content_stub.expects(:compress_stream).never

    pdf.instance_variable_set("@page_content", content_stub.identifier)
    pdf.text "Hi There" * 20
    pdf.render
  end

  it "should compress the page content stream if compression is enabled" do

    pdf = Prawn::Document.new(:compress => true)
    content_stub = pdf.ref!({})
    content_stub.stubs(:compress_stream).returns(true)
    content_stub.expects(:compress_stream).once

    pdf.instance_variable_set("@page_content", content_stub.identifier)
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

end       

describe "When setting page layout" do
  it "should reverse coordinates for landscape" do
    @pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages    
    pages.first[:size].should == Prawn::Document::PageGeometry::SIZES["A4"].reverse
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
    }.should.raise(Prawn::Document::CannotGroup)
  end

  it "should group within individual column boxes" do
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
  if "spec".respond_to?(:encode!)
    it "should return a 8 bit encoded string on a m17n aware VM" do
      @pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
      @pdf.line [100,100], [200,200]
      str = @pdf.render
      str.encoding.to_s.should == "ASCII-8BIT"
    end
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
