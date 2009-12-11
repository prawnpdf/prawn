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

    it "should incorporate padding when specified" do
      c = @pdf.cell(:content => "text", :padding => [1, 2, 3, 4])
      c.width.should.be.close(@pdf.width_of("text") + 6, 0.01)
    end

  end

  describe "cell padding" do
    it "should default to zero" do
      c = @pdf.cell(:content => "text")
      c.padding.should == [0, 0, 0, 0]
    end

    it "should accept a numeric value, setting all padding" do
      c = @pdf.cell(:content => "text", :padding => 10)
      c.padding.should == [10, 10, 10, 10]
    end

    it "should accept [v,h]" do
      c = @pdf.cell(:content => "text", :padding => [20, 30])
      c.padding.should == [20, 30, 20, 30]
    end

    it "should accept [t,l,b,r]" do
      c = @pdf.cell(:content => "text", :padding => [10, 20, 30, 40])
      c.padding.should == [10, 20, 30, 40]
    end

    it "should reject other formats" do
      lambda{
        @pdf.cell(:content => "text", :padding => [10])
      }.should.raise(ArgumentError)
    end
  end

end
