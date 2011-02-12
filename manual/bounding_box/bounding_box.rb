# encoding: utf-8
#
# Examples for bounding boxes.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("bounding_box.pdf") do
  build_package("bounding_box", [
      [ "Basics", [ "creation",
                    "bounds"
                  ]
      ],
      [ "Advanced", [ "stretchy",
                      "nesting",
                      "indentation",
                      "canvas"
                    ]
      ]
    ]
    
  ) do
    text "Bounding boxes are the basic containers for structuring the content flow. Even being low level building blocks sometimes their simplicity is very welcome.
    
    The examples show:"

    list( "How to create bounding boxes with specific dimensions",
          "How to inspect the current bounding box for its coordinates",
          "Stretchy bounding boxes",
          "Nested bounding boxes",
          "Indent blocks"
        )
  end
end
