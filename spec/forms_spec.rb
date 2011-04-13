# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "#form_fields" do
  it "should return an empty array if there is no form" do
    pdf = Prawn::Document.new
    pdf.form_fields.should == []
  end

  it "should return an array of the correct values when the template is a form" do
    filename = "#{Prawn::BASEDIR}/spec/data/form.pdf"
    pdf = Prawn::Document.new(:template => filename)
    pdf.form_fields.sort.should == ["name", "quest", "velocity"].sort
  end
end

describe "#fill_form" do
  it "should succeed even when there is no form" do
    pdf = Prawn::Document.new
    pdf.fill_form
  end

  it "should fill the form without error" do
    filename = "#{Prawn::BASEDIR}/spec/data/form.pdf"
    pdf = Prawn::Document.new(:template => filename)
    pdf.fill_form "name" => "Launcelot", "quest" => "To find the Grail", "velocity" => "African or European?"
  end
end
