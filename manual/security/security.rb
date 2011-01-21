# encoding: utf-8
#
# Examples for document encryption.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("security.pdf") do
  build_package("security", [
      [ "Basics", [ { :name => "encryption",
                      :eval_source => false,
                      :full_source => true }
                  ]
      ]
    ]
  )
end
