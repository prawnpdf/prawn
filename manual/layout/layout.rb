# encoding: utf-8
#
# Examples for using grid layouts.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("layout.pdf") do
  build_package("layout", [
      "simple_grid",
      "boxes",
      "content"
    ]

  ) do
    text "Prawn has support for two-dimensional grid based layouts out of the box.

    The examples show:"

    list( "How to define the document grid",
          "How to configure the grid rows and columns gutters",
          "How to create boxes according to the grid"
        )
  end
end
