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
      ],
      [ "Adding nodes later",
                  [ { :name => "add_subsection_to",
                      :eval_source => false },
                    { :name => "insert_section_after",
                      :eval_source => false }
                  ]
      ]
    ]
    
  ) do
    text "The outline of a PDF document is the table of contents tab you see to the right or left of your PDF viewer.

    The examples include:"

    list( "How to define sections and pages",
          "How to insert sections and/or pages to a previously defined outline structure"
        )
  end
end
