# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

describe "Table cells" do

  describe "cell width" do
    before(:each) do
      @pdf = Prawn::Document.new
    end

    def cell(options={})
      Prawn::Table::Cell.new(@pdf, [0, @pdf.cursor], options)
    end

    it "should be calculated for text" do
      c = cell(:content => "text")
      c.width.should == @pdf.width_of("text")
    end

    it "should be overridden by manual :width" do
      c = cell(:content => "text", :width => 400)
      c.width.should == 400
    end

  end

end
