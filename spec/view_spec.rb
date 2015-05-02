# encoding: utf-8

require_relative "spec_helper"

describe "Prawn::View" do
  let(:view_object) { Object.new.tap { |o| o.extend(Prawn::View) } }

  it "provides a Prawn::Document object by default" do
    expect(view_object.document).to be_kind_of(Prawn::Document)
  end

  it "delegates unhandled methods to object returned by document method" do
    doc = mock("Document")
    view_object.stubs(:document => doc)

    doc.expects(:some_delegated_method)

    view_object.some_delegated_method
  end

  it "allows a block-like DSL via the update method" do
    doc = mock("Document")
    view_object.stubs(:document => doc)

    doc.expects(:foo)
    doc.expects(:bar)

    view_object.update do
      foo
      bar
    end
  end

  it "aliases save_as() to document.render_file()" do
    doc = mock("Document")
    doc.expects(:render_file)

    view_object.stubs(:document => doc)

    view_object.save_as("foo.pdf")
  end
end
