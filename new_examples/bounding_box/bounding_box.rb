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
                      "indentation"
                    ]
      ],
    ]
  )
end
