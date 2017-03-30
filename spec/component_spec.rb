# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "#draw" do
  before :each do
    create_pdf
  end

  let(:mock_component) { mock "Mock Component" }

  it "passes supplied arguments to the passed object" do
    mock_component.expects(:call).with(@pdf, {arg1: true, arg2: false})
    @pdf.draw mock_component, arg1: true, arg2: false
  end
end
