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
    
  ) do
    text "A Stamp can be used for content blocks that need to be inserted multiple times in the document.

    The examples include:"

    list( "How to create a new Stamp",
          'How to "stamp" the content block on the page'
        )
  end
end
