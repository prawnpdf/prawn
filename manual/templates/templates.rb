# encoding: utf-8
#
# Examples for stamps.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("templates.pdf") do
  build_package("templates", [
      [ "Basics", [ { :name        => "full_template",
                      :eval_source => false,
                      :full_source => true
                    },
                    "page_template"
                  ]
      ]
    ]
    
  ) do
    text "Templates let you embed other pdf documents inside the current one.

    The examples show:"

    list( "How to load the whole content from another pdf",
          "How to load single pages from another pdf"
        )
  end
end
