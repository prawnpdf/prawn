# encoding: utf-8
#
# Examples for embedding images.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("images.pdf") do
  build_package("images", [
      [ "Basics", [ "plain_image",
                    "absolute_position"
                  ]
      ],
      [ "Relative Positioning", [ "horizontal",
                                  "vertical"
                                ]
      ],
      ["Size", [ "width_and_height",
                 "scale",
                 "fit"
               ]
      ]
    ]

  ) do
    text "Embedding images on PDF documents is fairly easy. Prawn supports both JPG and PNG images.

    The examples show:"

    list( "How to add an image to a page",
          "How place the image on a specific position",
          "How to configure the image dimensions by setting the width and height or by using scaling it"
        )
  end
end
