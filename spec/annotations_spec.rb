# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  
                               
class PageAnnotations
  attr_reader :pages

  def self.parse(document)
    receiver = new
    PDF::Reader.string(document.render, receiver)
    return receiver
  end

  def initialize
    @pages = []
  end

  def begin_page(params)
    @pages << params
  end
end

describe "When creating annotations" do 
 
  before(:each) { create_pdf }
  
  it "should append annotation to current page" do 
    @pdf.start_new_page
    @pdf.annotate(:Rect => [0,0,10,10], :Subtype => :Text, :Contents => "Hello world!")
    obj = PageAnnotations.parse(@pdf)
    obj.pages[0][:Annots].nil?.should == true
    obj.pages[1][:Annots].length.should == 1
  end

  it "should force :Type to be :Annot" do
    opts = @pdf.annotate(:Rect => [0,0,10,10], :Subtype => :Text, :Contents => "Hello world!")
    opts[:Type].should == :Annot
    opts = @pdf.annotate(:Type => :Bogus, :Rect => [0,0,10,10], :Subtype => :Text, :Contents => "Hello world!")
    opts[:Type].should == :Annot
  end

end

describe "When creating text annotations" do
 
  before(:each) do
    @rect = [0,0,10,10]
    @content = "Hello, world!"
    create_pdf
  end
  
  it "should build appropriate annotation" do 
    opts = @pdf.text_annotation(@rect, @content)
    opts[:Type].should == :Annot
    opts[:Subtype].should == :Text
    opts[:Rect].should == @rect
    opts[:Contents].should == @content
  end

  it "should merge extra options" do 
    opts = @pdf.text_annotation(@rect, @content, :Open => true, :Subtype => :Bogus)
    opts[:Subtype].should == :Text
    opts[:Open].should == true
  end

end

describe "When creating link annotations" do
 
  before(:each) do
    @rect = [0,0,10,10]
    @dest = "home"
    create_pdf
  end
  
  it "should build appropriate annotation" do 
    opts = @pdf.link_annotation(@rect, :Dest => @dest)
    opts[:Type].should == :Annot
    opts[:Subtype].should == :Link
    opts[:Rect].should == @rect
    opts[:Dest].should == @dest
  end

  it "should merge extra options" do 
    opts = @pdf.link_annotation(@rect, :Dest => @dest, :Subtype => :Bogus)
    opts[:Subtype].should == :Link
    opts[:Dest].should == @dest
  end

end
