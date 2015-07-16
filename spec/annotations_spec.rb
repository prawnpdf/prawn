# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "When creating annotations" do
  before(:each) { create_pdf }

  it "should append annotation to current page" do
    @pdf.start_new_page
    @pdf.annotate(:Rect => [0, 0, 10, 10], :Subtype => :Text, :Contents => "Hello world!")
    PDF::Reader.open(StringIO.new(@pdf.render)) do |pdf|
      expect(pdf.page(1).attributes[:Annots]).to be_nil
      expect(pdf.page(2).attributes[:Annots].size).to eq(1)
    end
  end

  it "should force :Type to be :Annot" do
    opts = @pdf.annotate(:Rect => [0, 0, 10, 10], :Subtype => :Text, :Contents => "Hello world!")
    expect(opts[:Type]).to eq(:Annot)
    opts = @pdf.annotate(:Type => :Bogus, :Rect => [0, 0, 10, 10], :Subtype => :Text, :Contents => "Hello world!")
    expect(opts[:Type]).to eq(:Annot)
  end
end

describe "When creating text annotations" do
  before(:each) do
    @rect = [0, 0, 10, 10]
    @content = "Hello, world!"
    create_pdf
  end

  it "should build appropriate annotation" do
    opts = @pdf.text_annotation(@rect, @content)
    expect(opts[:Type]).to eq(:Annot)
    expect(opts[:Subtype]).to eq(:Text)
    expect(opts[:Rect]).to eq(@rect)
    expect(opts[:Contents]).to eq(@content)
  end

  it "should merge extra options" do
    opts = @pdf.text_annotation(@rect, @content, :Open => true, :Subtype => :Bogus)
    expect(opts[:Subtype]).to eq(:Text)
    expect(opts[:Open]).to eq(true)
  end
end

describe "When creating link annotations" do
  before(:each) do
    @rect = [0, 0, 10, 10]
    @dest = "home"
    create_pdf
  end

  it "should build appropriate annotation" do
    opts = @pdf.link_annotation(@rect, :Dest => @dest)
    expect(opts[:Type]).to eq(:Annot)
    expect(opts[:Subtype]).to eq(:Link)
    expect(opts[:Rect]).to eq(@rect)
    expect(opts[:Dest]).to eq(@dest)
  end

  it "should merge extra options" do
    opts = @pdf.link_annotation(@rect, :Dest => @dest, :Subtype => :Bogus)
    expect(opts[:Subtype]).to eq(:Link)
    expect(opts[:Dest]).to eq(@dest)
  end
end
