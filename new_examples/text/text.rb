# encoding: utf-8
#
# Examples for text rendering.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("text.pdf") do
  build_package("text", [
      [ "Basics", [ "simple",
                    "positioned"
                  ]
      ],
      [ "Fonts", [ "font",
                   "font_size"
                 ]
      ],
      [ "Styling", [
                   ]
      ]
    ]
  )
end
