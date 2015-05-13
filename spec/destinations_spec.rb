# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "When creating destinations" do
  before(:each) { create_pdf }

  it "should add entry to Dests name tree" do
    expect(@pdf.dests.data.empty?).to eq(true)
    @pdf.add_dest "candy", "chocolate"
    expect(@pdf.dests.data.size).to eq(1)
  end
end
