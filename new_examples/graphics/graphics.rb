# encoding: utf-8
#
# Generates example document for the Graphics package
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("graphics.pdf") do
  build_package("graphics", [
      [ "Basics", [ "helper",
                    "origin",
                    "fill_and_stroke"
                  ]
      ],
      [ "Shapes", [ "lines_and_curves",
                    "common_lines",
                    "rectangle",
                    "polygon",
                    "circle_and_ellipse"
                  ]
      ],
      [ "Fill and Stroke settings", [ "line_width",
                                      "stroke_cap",
                                      "stroke_join",
                                      "stroke_dash",
                                      "color",
                                      "transparency"
                                    ]
      ],
      [ "Transformations", [ "rotate",
                             "translate",
                             "scale"
                           ]
      ]
    ]
  )
end
