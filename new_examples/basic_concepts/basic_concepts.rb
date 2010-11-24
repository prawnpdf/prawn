# encoding: utf-8
#
# Examples for Prawn basic concepts.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("basic_concepts.pdf") do
  build_package("basic_concepts", [
      { :name => "creation", :eval_source => false, :full_source => true }
    ]
  )
end
