# encoding: utf-8
#
# Examples for creating new PDF documents with Prawn.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("text.pdf") do
  build_package("text", [
      [ "Basics", [ "simple"
                  ]
      ]
    ]
  )
end
