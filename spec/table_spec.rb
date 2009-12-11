# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

describe "Prawn::Table::Cell" do
  before(:each) do
    @pdf = Prawn::Document.new
  end

  describe "Prawn::Document#cell" do
    it "should draw the cell" do
      Prawn::Table::Cell.any_instance.expects(:draw).once
      @pdf.cell(:content => "text")
    end

    it "should return a Cell" do
      @pdf.cell(:content => "text").should.be.an.instance_of Prawn::Table::Cell
    end
  end

  describe "cell width" do
    it "should be calculated for text" do
      c = @pdf.cell(:content => "text")
      c.width.should == @pdf.width_of("text")
    end

    it "should be overridden by manual :width" do
      c = @pdf.cell(:content => "text", :width => 400)
      c.width.should == 400
    end

  end

end
