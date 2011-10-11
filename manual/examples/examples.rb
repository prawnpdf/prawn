# encoding: utf-8
#
# Miscellaneous comprehensive examples.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("examples.pdf") do
  build_package("examples", [
      # TODO
      "russian_boxes"
    ]

  ) do
    text "This section gathers some comprehensive examples that showcase
      various features of Prawn but didn't fit elsewhere in the manual. Some of
      these are just for fun!"
  end
end
