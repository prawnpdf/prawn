# encoding: utf-8
#
# Examples for the Graphics package.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("graphics.pdf") do
  build_package("graphics", [
      [ "Basics", [ "helper",
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
    
  ) do
    text "Here we show all the drawing methods provided by Prawn. Use them to draw the most beautiful imaginable things.
    
    Most of the content that you'll add to your pdf document will use the graphics package. Even text is rendered on a page just like a rectangle is so even if you never use any of the shapes described here you should at least read the basic examples.
    
    The examples show:"
    
    list( "All the possible ways that you can fill or stroke shapes on a page",
          "How to draw all the shapes that Prawn has to offer from a measly line to a mighty polygon or ellipse",
          "What the configuration options are for stroking lines and filling shapes.",
          "How to apply transformations to your drawing space"
        )
  end
end
