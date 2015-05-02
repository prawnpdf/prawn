# encoding: utf-8
#
# Examples for bounding boxes.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::ManualBuilder::Example.generate("bounding_box.pdf", :page_size => "FOLIO") do
  package "bounding_box" do |p|
    p.section "Basics" do |s|
      s.example "creation"
      s.example "bounds"
    end

    p.section "Advanced" do |s|
      s.example "stretchy"
      s.example "nesting"
      s.example "indentation"
      s.example "canvas"
      s.example "russian_boxes"
    end

    p.intro do
      prose("Bounding boxes are the basic containers for structuring the content flow. Even being low level building blocks sometimes their simplicity is very welcome.

      The examples show:")

      list( "How to create bounding boxes with specific dimensions",
            "How to inspect the current bounding box for its coordinates",
            "Stretchy bounding boxes",
            "Nested bounding boxes",
            "Indent blocks"
          )
    end
  end
end
