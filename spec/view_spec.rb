# encoding: utf-8

require_relative "spec_helper"

describe "Prawn::View" do
  let(:view_object) { Object.new.tap { |o| o.extend(Prawn::View) } }

  it "provides a Prawn::Document object by default" do
    expect(view_object.document).to be_kind_of(Prawn::Document)
  end

  it "delegates unhandled methods to object returned by document method" do
    doc = double("Document")
    allow(view_object).to receive(:document).and_return(doc)

    expect(doc).to receive(:some_delegated_method)

    view_object.some_delegated_method
  end

  it "allows a block-like DSL via the update method" do
    doc = double("Document")
    allow(view_object).to receive(:document).and_return(doc)

    expect(doc).to receive(:foo)
    expect(doc).to receive(:bar)

    view_object.update do
      foo
      bar
    end
  end

  it "aliases save_as() to document.render_file()" do
    doc = double("Document")
    expect(doc).to receive(:render_file)

    allow(view_object).to receive(:document).and_return(doc)

    view_object.save_as("foo.pdf")
  end
end
