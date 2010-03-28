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

  it "should not add an extra restore_graphics_state operator to the end of any content stream" do
    filename = "#{Prawn::BASEDIR}/reference_pdfs/curves.pdf"

    @pdf = Prawn::Document.new(:template => filename)
    output = StringIO.new(@pdf.render)
    @pdf.render_file("bar.pdf")
    hash = PDF::Hash.new(output)

    hash.each_value do |obj|
      next unless obj.kind_of?(PDF::Reader::Stream)

      data = obj.data.tr(" \n\r","")
      data.include?("QQ").should == false
    end

  end

end
