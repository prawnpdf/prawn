# encoding: utf-8
#
# Examples for using grid layouts.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::ManualBuilder::Example.generate("layout.pdf", :page_size => "FOLIO") do

  package "layout" do |p|

    p.example "simple_grid"
    p.example "boxes"
    p.example "content"

    p.intro do
      prose("Prawn has support for two-dimensional grid based layouts out of the box.

      The examples show:")

      list( "How to define the document grid",
            "How to configure the grid rows and columns gutters",
            "How to create boxes according to the grid"
          )
    end

  end
end
