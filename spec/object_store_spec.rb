# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Prawn::ObjectStore" do
  before(:each) do
    @store = Prawn::Core::ObjectStore.new
  end

  it "should create required roots by default, including info passed to new" do
    store = Prawn::Core::ObjectStore.new(:info => {:Test => 3})
    store.size.should == 3 # 3 default roots
    store.info.data[:Test].should == 3
    store.pages.data[:Count].should == 0
    store.root.data[:Pages].should == store.pages
  end

  it "should import objects from an existing PDF" do
    filename = "#{Prawn::BASEDIR}/spec/data/curves.pdf"
    store = Prawn::Core::ObjectStore.new(:template => filename)
    store.size.should == 5
  end

  it "should point to existing roots when importing objects from an existing PDF" do
    filename = "#{Prawn::BASEDIR}/spec/data/curves.pdf"
    store = Prawn::Core::ObjectStore.new(:template => filename)
    store.info.class.should == Prawn::Core::Reference
    store.root.class.should == Prawn::Core::Reference
  end

  it "should initialize with pages when importing objects from an existing PDF" do
    filename = "#{Prawn::BASEDIR}/spec/data/curves.pdf"
    store = Prawn::Core::ObjectStore.new(:template => filename)
    store.pages.data[:Count].should == 1
  end

  it "should import all objects from a PDF that has an indirect reference in a stream dict" do
    filename = "#{Prawn::BASEDIR}/data/pdfs/indirect_reference.pdf"
    store = Prawn::Core::ObjectStore.new(:template => filename)
    store.size.should == 8
  end

  it "should raise ArgumentError when given a file that doesn exist as a template" do
    filename = "not_really_there.pdf"

    lambda { Prawn::Core::ObjectStore.new(:template => filename) }.should.raise(ArgumentError)
  end

  it "should raise Prawn::Errors::TemplateError when given a non PDF as a template" do
    filename = "#{Prawn::BASEDIR}/data/images/dice.png"

    lambda { Prawn::Core::ObjectStore.new(:template => filename) }.should.raise(Prawn::Errors::TemplateError)
  end

  it "should raise Prawn::Errors::TemplateError when given an encrypted PDF as a template" do
    filename = "#{Prawn::BASEDIR}/data/pdfs/encrypted.pdf"

    lambda { Prawn::Core::ObjectStore.new(:template => filename) }.should.raise(Prawn::Errors::TemplateError)
  end

  it "should add to its objects when ref() is called" do
    count = @store.size
    @store.ref("blah")
    @store.size.should == count + 1
  end

  it "should accept push with a Prawn::Reference" do
    r = Prawn::Core::Reference(123, "blah")
    @store.push(r)
    @store[r.identifier].should == r
  end

  it "should accept arbitrary data and use it to create a Prawn::Reference" do
    @store.push(123, "blahblah")
    @store[123].data.should == "blahblah"
  end

  it "should be Enumerable, yielding in order of submission" do
    # higher IDs to bypass the default roots
    [10, 11, 12].each do |id|
      @store.push(id, "some data #{id}")
    end
    @store.map{|ref| ref.identifier}[-3..-1].should == [10, 11, 12]
  end
end

describe "Prawn::ObjectStore#compact" do
  it "should do nothing to an ObjectStore with all live refs" do
    store = Prawn::Core::ObjectStore.new
    store.info.data[:Blah] = store.ref(:some => "structure")
    old_size = store.size
    store.compact

    store.size.should == old_size
  end

  it "should remove dead objects, renumbering live objects from 1" do
    store = Prawn::Core::ObjectStore.new
    store.ref(:some => "structure")
    old_size = store.size
    store.compact
    
    store.size.should.be < old_size
    store.map{ |o| o.identifier }.should == (1..store.size).to_a
  end

  it "should detect and remove dead objects that were once live" do
    store = Prawn::Core::ObjectStore.new
    store.info.data[:Blah] = store.ref(:some => "structure")
    store.info.data[:Blah] = :overwritten
    old_size = store.size
    store.compact
    
    store.size.should.be < old_size
    store.map{ |o| o.identifier }.should == (1..store.size).to_a
  end
end

describe "Prawn::ObjectStorie#object_id_for_page" do
  it "should return the object ID of an imported template page" do
    filename = "#{Prawn::BASEDIR}/data/pdfs/hexagon.pdf"
    store = Prawn::Core::ObjectStore.new(:template => filename)
    store.object_id_for_page(0).should == 4
  end

  it "should return the object ID of the first imported template page" do
    filename = "#{Prawn::BASEDIR}/data/pdfs/two_hexagons.pdf"
    store = Prawn::Core::ObjectStore.new(:template => filename)
    store.object_id_for_page(1).should == 4
  end

  it "should return the object ID of the last imported template page" do
    filename = "#{Prawn::BASEDIR}/data/pdfs/two_hexagons.pdf"
    store = Prawn::Core::ObjectStore.new(:template => filename)
    store.object_id_for_page(-1).should == 6
  end

  it "should return the object ID of the first page of a template that uses nested Pages" do
    filename = "#{Prawn::BASEDIR}/data/pdfs/nested_pages.pdf"
    store = Prawn::Core::ObjectStore.new(:template => filename)
    store.object_id_for_page(1).should == 5
  end

  it "should return the object ID of the last page of a template that uses nested Pages" do
    filename = "#{Prawn::BASEDIR}/data/pdfs/nested_pages.pdf"
    store = Prawn::Core::ObjectStore.new(:template => filename)
    store.object_id_for_page(-1).should == 8
  end

  it "should return nil if given an invalid page number" do
    filename = "#{Prawn::BASEDIR}/data/pdfs/hexagon.pdf"
    store = Prawn::Core::ObjectStore.new(:template => filename)
    store.object_id_for_page(10).should == nil
  end

  it "should return nil if given an invalid page number" do
    store = Prawn::Core::ObjectStore.new
    store.object_id_for_page(10).should == nil
  end

  it "should accept a stream instead of a filename" do
    example = Prawn::Document.new()
    example.text "An example doc, created in memory"
    example.start_new_page
    StringIO.open(example.render) do |stream|
      @pdf = Prawn::Core::ObjectStore.new(:template => stream)
    end
    @pdf.page_count.should == 2
  end
end
