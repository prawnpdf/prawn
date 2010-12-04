# encoding: utf-8
#
# Examples for defining the document outline.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("outline.pdf") do
  build_package("outline", [
      [ "Basics", [ { :name => "sections_and_pages",
                      :eval_source => false }
                  ]
      ]
    ]
  )
end
