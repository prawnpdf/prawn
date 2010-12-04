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
      ]
    ]
  )
end
