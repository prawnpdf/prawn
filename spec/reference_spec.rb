# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "A Reference object" do
  describe "generated via Prawn::Document" do
    it "should return a proper reference on ref!" do
      pdf = Prawn::Document.new
      expect(pdf.ref!({}).is_a?(PDF::Core::Reference)).to eq(true)
    end

    it "should return an identifier on ref" do
      pdf = Prawn::Document.new
      r = pdf.ref({})
      expect(r.is_a?(Integer)).to eq(true)
    end

    it "should have :Length of stream if it has one when compression disabled" do
      pdf = Prawn::Document.new :compress => false
      ref = pdf.ref!({})
      ref << 'Hello'
      expect(ref.stream.data[:Length]).to eq(5)
    end
  end
end
