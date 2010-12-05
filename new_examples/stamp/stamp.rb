# encoding: utf-8
#
# Examples for stamps.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("stamp.pdf") do
  build_package("stamp", [
      [ "Basics", [ "create_and_stamp"
                  ]
      ]
    ]
  )
end
