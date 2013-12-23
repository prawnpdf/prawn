# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "When creating destinations" do

  before(:each) { create_pdf }

  it "should add entry to Dests name tree" do
    @pdf.dests.data.empty?.should == true
    @pdf.add_dest "candy", "chocolate"
    @pdf.dests.data.size.should == 1
  end

end
