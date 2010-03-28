require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Document built from a template" do

  it "should have the same page count as the source document" do
    filename = "#{Prawn::BASEDIR}/reference_pdfs/curves.pdf"
    @pdf = Prawn::Document.new(:template => filename)
    page_counter = PDF::Inspector::Page.analyze(@pdf.render)

    @pdf.page_count.should == 1
  end

  it "should have start with the Y cursor at the top of the document" do
    filename = "#{Prawn::BASEDIR}/reference_pdfs/curves.pdf"

    @pdf = Prawn::Document.new(:template => filename)
    (@pdf.y == nil).should == false
  end
end
